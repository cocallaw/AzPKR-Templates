$ErrorActionPreference = "Stop"
$WVDSetupFslgxPath = "C:\WVDSetup\fslogix"
$fslgxURI = "https://aka.ms/fslogix_download"
$FSLInstallerEXE = "$WVDSetupFslgxPath\x64\Release\FSLogixAppsSetup.exe"

#FSLogix download and installs
function Get-FSLogix {
    New-Item -Path $WVDSetupFslgxPath -ItemType Directory -Force
    Invoke-WebRequest -Uri $fslgxURI -OutFile "$WVDSetupFslgxPath\FSLogix_Apps.zip" -UseBasicParsing
    #Start-BitsTransfer -Source $fslgxURI -Destination "$WVDSetupFslgxPath\FSLogix_Apps.zip"
    Write-Host "Downloaded FSLogix to $WVDSetupFslgxPath"
    Write-Host "Expanding and cleaning up Fslogix.zip"
    Expand-Archive "$WVDSetupFslgxPath\FSLogix_Apps.zip" -DestinationPath "$WVDSetupFslgxPath" -ErrorAction SilentlyContinue
    Remove-Item "$WVDSetupFslgxPath\FSLogix_Apps.zip"
}

function Install-FSLogix {
    Write-Host "Installing FSLogix Agent on $env:COMPUTERNAME"
    & $FSLInstallerEXE -install
    Write-Host "FSLogix Installer Has Completed"
}
function Install-VSCode {
    Write-Host "Installing VS Code on $env:COMPUTERNAME"
    Start-Process -FilePath "Z:\VSCode\VSCodeSetup-x64-1.54.1.exe" -ArgumentList "/VERYSILENT /NORESTART /MERGETASKS=!runcode" -Wait -NoNewWindow
    Write-Host "VS Code Installer Has Completed - REBOOTING"
}

Start-Process -FilePath "Z:\VisualC\VC_redist.x64.exe" -ArgumentList "/install /quiet /norestart" -Wait -NoNewWindow
Start-Process -FilePath "Z:\WebRTC\MsRdcWebRTCSvc_x64.msi" -ArgumentList "/quiet /norestart" -Wait -NoNewWindow
msiexec /i "Z:\Teams\Teams_windows_x64.exe" ALLUSER=1
    
$key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Teams"

foreach ($k in $key) {
    If ( -Not ( Test-Path "Registry::$k")) { New-Item -Path "Registry::$k" -ItemType RegistryKey -Force }
    Set-ItemProperty -path "Registry::$k" -Name "IsWVDEnvironment" -Type "DWord" -Value "00000001"
}

Start-Sleep -Seconds 5

Get-FSLogix
Install-FSLogix
Install-VSCode
& shutdown -r -t 0