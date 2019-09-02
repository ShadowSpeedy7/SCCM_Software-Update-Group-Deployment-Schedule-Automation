Set-ExecutionPolicy -Scope Process Bypass
Add-Type -AssemblyName System.Windows.Forms
#test

$CMsite = 'BOB'

Set-Location 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
import-module .\ConfigurationManager.psd1
Set-Location $cmsite':'

#Get path for where to save CSV
$SaveFile = New-Object -Typename System.Windows.Forms.SaveFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'CSV File|*.csv'
    DefaultExt = 'csv'
    Title = 'Select a Destination'
}
$null = $SaveFile.ShowDialog()
if ('' -eq $SaveFile.FileName) {
    Write-Host "No File Selected"
    exit
}
$SaveFile = $SaveFile.FileName

#Montly-Updates SUG
$SUGid = Read-Host  'Enter "Config Item ID" for the Software Update Group'

#Get the exact name of the SUG
$SUGName = Get-CMSoftwareUpdateGroup -ID $SUGid
$SUGName = $SUGName.LocalizedDisplayName

Get-CMDeployment -FeatureType SoftwareUpdate -SoftwareName $SUGName | Where-Object {$_.CI_ID -eq $SUGid} |
    Select-Object -Property ApplicationName,AssignmentID,CollectionName,DeploymentTime,EnforcementDeadline |
    Export-Csv -LiteralPath $SaveFile -NoTypeInformation

pause