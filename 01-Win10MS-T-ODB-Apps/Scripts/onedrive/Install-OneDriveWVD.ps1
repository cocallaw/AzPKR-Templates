Write-Host "Starting Onedrive Install for WVD"

Write-Host "Creating Temp ODB Working Directory"
$otd = "C:\odbtemp"
New-Item -Path $otd -ItemType Directory -Force

Write-Host "Downloading latest OnedDrive Client"
$odburi = "https://aka.ms/OneDriveWVD-Installer"
try {
    Start-BitsTransfer -Source $odburi -Destination "$otd\OneDriveSetup.exe"
}
catch {
    Invoke-WebRequest -Uri $odburi -OutFile "$otd\OneDriveSetup.exe"
}

Write-Host "Installing OneDrive in Per-Machine Mode"
Start-Process "$otd\OneDriveSetup.exe" -ArgumentList "/allusers"

Write-Host "Waiting on OneDrive Install 90 Seconds"
Start-Sleep -Seconds 60
Write-Host "Waiting on OneDrive Install 30 Seconds Remaining"
Start-Sleep -Seconds 60

Write-Host "Setting OneDrive to start at Sign-in for all users"
REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /t REG_SZ /d "C:\Program Files (x86)\Microsoft OneDrive\OneDrive.exe /background" /f

Start-Sleep -Seconds 2

Write-Host "Removing Temp ODB Working Directory"
Remove-Item "$otd" -Recurse