Write-Host "Starting Teams Install for WVD"

Write-Host "Creating Temp Teams Working Directory"
$ttd = "C:\teamstemp"
New-Item -Path $ttd -ItemType Directory -Force

Write-Host "Setting Teams IsWVDEnvironment Registry Key"
$key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Teams"

foreach ($k in $key) {
    If ( -Not ( Test-Path "Registry::$k")) { New-Item -Path "Registry::$k" -ItemType RegistryKey -Force }
    Set-ItemProperty -path "Registry::$k" -Name "IsWVDEnvironment" -Type "DWord" -Value "00000001"
}

Write-Host "Downloading latest WebRTC Service"
$rtcuri = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4AQBt"
try {
    Start-BitsTransfer -Source $rtcuri -Destination "$ttd\MsRdcWebRTCSvc_x64.msi"
}
catch {
    Invoke-WebRequest -Uri $rtcuri -OutFile "$ttd\MsRdcWebRTCSvc_x64.msi"
}

Write-Host "Downloading latest Visual C++"
$vcuri = "https://aka.ms/vs/16/release/vc_redist.x64.exe"
try {
    Start-BitsTransfer -Source $vcuri -Destination "$ttd\VC_redist.x64.exe"
}
catch {
    Invoke-WebRequest -Uri $vcuri -OutFile "$ttd\VC_redist.x64.exe"
}

Write-Host "Downloading latest Microsoft Teams Client"
$tmsuri = "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"
try {
    Start-BitsTransfer -Source $tmsuri -Destination "$ttd\Teams_windows_x64.msi"
}
catch {
    Invoke-WebRequest -Uri $tmsuri -OutFile "$ttd\Teams_windows_x64.msi"
}

Write-Host "Installing C++"
Start-Process -FilePath "$ttd\VC_redist.x64.exe" -ArgumentList "/install /quiet /norestart" -Wait -NoNewWindow
Write-Host "Installing WebRTC"
Start-Process -FilePath "$ttd\MsRdcWebRTCSvc_x64.msi" -ArgumentList "/quiet /norestart" -Wait -NoNewWindow
Write-Host "Installing Teams Client"
msiexec /i "$ttd\Teams_windows_x64.msi" ALLUSER=1

Start-Sleep -Seconds 2

Write-Host "Removing Temp Teams Working Directory"
Remove-Item "$ttd" -Recurse