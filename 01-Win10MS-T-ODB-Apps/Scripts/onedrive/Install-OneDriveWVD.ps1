Write-Host "Starting Onedrive Install for WVD"

Write-Host "Creating Temp ODB Working Directory"
$otd = "C:\odbtemp"
New-Item -Path $otd -ItemType Directory -Force

Write-Host "Setting OneDrive AllUsersInstall Registry Key"
$key = "HKEY_LOCAL_MACHINE\Microsoft\OneDrive"

foreach ($k in $key) {
    If ( -Not ( Test-Path "Registry::$k")) { New-Item -Path "Registry::$k" -ItemType RegistryKey -Force }
    Set-ItemProperty -path "Registry::$k" -Name "AllUsersInstall" -Type "DWord" -Value "00000001"
}

Write-Host "Downloading latest OnedDrive Client"
$odburi = "https://aka.ms/OneDriveWVD-Installer"
try {
    Start-BitsTransfer -Source $odburi -Destination "$otd\OneDriveSetup.exe"
}
catch {
    Invoke-WebRequest -Uri $odburi -OutFile "$otd\OneDriveSetup.exe"
}

Write-Host "Installing OneDrive in Per-Machine Mode"
& "$otd\OneDriveSetup.exe" /allusers

Write-Host "Setting OneDrive to start at Sign-in for all users"
REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /t REG_SZ /d "C:\Program Files (x86)\Microsoft OneDrive\OneDrive.exe /background" /f

Start-Sleep -Seconds 2

Write-Host "Removing Temp ODB Working Directory"
Remove-Item "$otd" -Recurse