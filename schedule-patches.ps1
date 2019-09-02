Set-ExecutionPolicy -Scope Process Bypass
Add-Type -AssemblyName System.Windows.Forms

$CMsite = 'BOB'

Set-Location 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
import-module .\ConfigurationManager.psd1
Set-Location $cmsite':'

#get csv of info
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'CSV File|*.csv'
}
$null = $FileBrowser.ShowDialog()
if ('' -eq $FileBrowser.FileName) {
    Write-Host "No File Selected"
    exit
}

$PatchSchedule = Import-Csv -Path $FileBrowser.FileName
$PatchingJobs = Get-CMSoftwareUpdateDeployment

for($i = 0; $i -lt $PatchSchedule.count; $i++) {
    $obj = $PatchingJobs | Where-Object {$_.AssignmentID -eq $PatchSchedule[$i].AssignmentID}
    Set-CMSoftwareUpdateDeployment -InputObject $obj -Enable $False -AvailableDateTime $PatchSchedule[$i].DeploymentTime -DeploymentExpireDateTime $PatchSchedule[$i].EnforcementDeadline
}
Pause
