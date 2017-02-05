Write-Output "PowerShell Timer trigger function executed at: $(get-date)";

#Hint Hint, you should not hard-code these, but instead store and retrieve them!
$azureAccountName = "XXXXXXX"
$azurePassword = ConvertTo-SecureString "XXXXXXX" -AsPlainText -Force
$ResourceGroupName = 'XXXXXXX'
$WorkspaceName = 'XXXXXXX'

$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

$Login = Login-AzureRmAccount -Credential $psCred 

$OMSQUERY = '(Type=Heartbeat) | measure max(TimeGenerated) as LastCall by Computer'

#Probably Best to use Saved Searchs!
$OMSResults = Get-AzureRmOperationalInsightsSearchResults  -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -Query $OMSQUERY
foreach($Result in $OMSResults.value)
{

   $ResultObj = ConvertFrom-Json $Result
   $Computer = $ResultObj.Computer
   $LastCheckIn = (get-date $ResultObj.LastCall).ToString('F')

   $ResultString = "Server Heartbeat check: Computer: $Computer last checked in at: $LastCheckIn"
   
   Write-Output $ResultString #Just for Debugging in the Azure Function Console

   Out-file -encoding Ascii -FilePath $res -InputObject $ResultString

}

Write-Output "PowerShell Timer trigger Completed at:$(get-date)";



