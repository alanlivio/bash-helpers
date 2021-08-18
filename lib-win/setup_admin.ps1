# ---------------------------------------
# utils
# ---------------------------------------
$bh_log_func = 'Write-Host -ForegroundColor DarkYellow "--" $MyInvocation.MyCommand.ToString()'

function bh_log() {
  Write-Host -ForegroundColor DarkYellow "--" ($args -join " ")
}

function bh_user_is_admin() {
  return (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ---------------------------------------
# reg
# ---------------------------------------

function bh_reg_new_path ($path) {
  if (-not (Test-Path $path)) {
    New-Item -Path $path -ItemType Directory -Force | Out-Null
  }
}

# ---------------------------------------
# env
# ---------------------------------------

function bh_env_add($name, $value) {
  [System.Environment]::SetEnvironmentVariable("$name", "$value", 'machine')
}

function bh_path_add($addPath) {
  if (Test-Path $addPath) {
    $currentpath = [System.Environment]::GetEnvironmentVariable('PATH', 'machine')
    $regexAddPath = [regex]::Escape($addPath)
    $arrPath = $currentpath -split ';' | Where-Object { $_ -notMatch "^$regexAddPath\\?" }
    $newpath = ($arrPath + $addPath) -join ';'
    bh_env_add 'PATH' $newpath
    refreshenv | Out-null
  }
  else {
    Throw "$addPath' is not a valid path."
  }
}

# ---------------------------------------
# scheduledtask
# ---------------------------------------

function bh_scheduledtask_list_enabled() {
  Get-ScheduledTask | Where-Object { $_.State -eq "Ready" }
}

function bh_scheduledtask_list_enabled() {
  Get-ScheduledTask | Where-Object { $_.State -eq "Disabled" }
}

function bh_scheduledtask_disable() {
  foreach ($name in $args) {
    Invoke-Expression $bh_log_func" "$name
    Disable-ScheduledTask -TaskName $name | Out-null
  }
}

# ---------------------------------------
# service
# ---------------------------------------


# ---------------------------------------
# service
# ---------------------------------------

function bh_service_list_running() {
  Get-Service | Where-Object { $_.Status -eq "Running" }
}

function bh_service_list_enabled() {
  Get-Service | Where-Object { $_.StartType -eq "Automatic" }
}

function bh_service_list_disabled() {
  Get-Service | Where-Object { $_.StartType -eq "Disabled" }
}

function bh_service_disable($name) {
  foreach ($name in $args) {
    Invoke-Expression $bh_log_func" "$name
    Get-Service -Name $name | Stop-Service -WarningAction SilentlyContinue
    Get-Service -Name $ame | Set-Service -StartupType Disabled -ea 0
  }
}

# ---------------------------------------
# winpackage
# ---------------------------------------

function bh_winpackage_list_enabled() {
  Get-WindowsPackage -Online | Where-Object PackageState -like Installed | ForEach-Object { $_.PackageName }
}

function bh_winpackage_disable_like() {
  Invoke-Expression $bh_log_func
  foreach ($name in $args) {
    $pkgs = Get-WindowsPackage -Online | Where-Object PackageState -like Installed | Where-Object PackageName -like $name
    if ($pkgs) {
      Invoke-Expression $bh_log_func" "$name
      $pkgs | ForEach-Object { Remove-WindowsPackage -Online -NoRestart $_ }
    }
  }
}

# ---------------------------------------
# feature
# ---------------------------------------

function bh_feature_enable($featurename) {
  Invoke-Expression "$bh_log_func $featurename"
  gsudo dism.exe /online /quiet /enable-feature /featurename:$featurename /all/norestart
}

function bh_feature_disable($featurename) {
  Invoke-Expression "$bh_log_func $featurename"
  gsudo dism.exe /online /quiet /disable-feature /featurename:$featurename /norestart
}

$MSYS_HOME = "C:\msys64"
function bh_msys_add_to_path() {
  bh_path_add "$MSYS_HOME\usr\bin"
  bh_path_add "$MSYS_HOME\mingw64\bin"
}


# ---------------------------------------
# wsl
# ---------------------------------------

function bh_wsl_get_default() {
  [System.Text.Encoding]::Unicode.GetString([System.Text.Encoding]::UTF8.GetBytes((wsl -l))) -split '\s\s+' | ForEach-Object {
    if ($_.Contains('(')) {
      return $_.Split(' ')[0]
    }
  }
}

function bh_wsl_get_default_version() {
  Foreach ($i in (wsl -l -v)) {
    if ($i.Contains('*')) {
      return $i.Split(' ')[-1]
    }
  }
}

function bh_wsl_terminate() {
  wsl -t (bh_wsl_get_default)
}

function bh_wsl_set_version2() {
  wsl --set-version (bh_wsl_get_default) 2
}

function bh_wsl_fix_home() {
  Invoke-Expression $bh_log_func
  # fix file metadata
  # https://docs.microsoft.com/en-us/windows/wsl/wsl-config
  # https://github.com/Microsoft/WSL/issues/3138
  # https://devblogs.microsoft.com/commandline/chmod-chown-wsl-improvements/
  wsl -u root bash -c 'echo "[automount]" > /etc/wsl.conf'
  wsl -u root bash -c 'echo "enabled=true" >> /etc/wsl.conf'
  wsl -u root bash -c 'echo "root=/mnt" >> /etc/wsl.conf'
  wsl -u root bash -c 'echo "mountFsTab=false" >> /etc/wsl.conf'
  wsl -u root bash -c 'echo "options=\"metadata,uid=1000,gid=1000,umask=0022,fmask=11\"" >> /etc/wsl.conf'
  # useful links /Users and /c
  wsl -u root bash -c 'if ! test -d /Users; then sudo ln -s /mnt/c/Users /Users; fi'
  wsl -u root bash -c 'if ! test -d /c; then sudo ln -s /mnt/c/ /c; fi'

  bh_wsl_terminate

  # enable sudoer
  wsl -u root usermod -aG sudo "$env:UserName"
  wsl -u root usermod -aG root "$env:UserName"

  # change default folder to /mnt/c/Users/
  wsl -u root skill -KILL -u $env:UserName
  wsl -u root usermod -d /mnt/c/Users/$env:UserName $env:UserName
  
  # delete the folder at /home/ and create a link to one at /mnt/c/Users/
  wsl -u root rm -rf  /home/$env:UserName
  wsl -u root ln -s /mnt/c/Users/$env:UserName /home/$env:UserName

  # changing file permissions
  bh_log "Changing file permissions "
  wsl -u root chown $env:UserName:$env:UserName /mnt/c/Users/$env:UserName/*
}

# ---------------------------------------
# msys
# ---------------------------------------

function bh_msys_sanity() {
  Set-Alias -Name msysbash -Value C:\msys64\usr\bin\bash.exe # TODO: replace by $MSYS_BASH 
  msysbash -c 'echo none / cygdrive binary,posix=0,noacl,user 0 0 > /etc/fstab'
  # mount /Users to use in both windows and WSL
  msysbash -c 'echo C:/Users/ /Users ntfs binary,noacl,auto 1 1 >>  /etc/fstab'
  # mount /Users/user-name
  msysbash -c 'echo C:/Users/$env:UserName /home/$env:UserName ntfs binary,noacl,auto 1 1 >> /etc/fstab'
  # mount /mnt/c/ like in WSL
  msysbash -c ' echo /c /mnt/c none bind >> /etc/fstab'
  # set home as /mnt/c/Users/user-name
  # msysbash -c "sed -i 's|db_home: cygwin desc|db_home: windows|g' /etc/nsswitch.conf"
  msysbash -c ' echo db_home: windows >> /etc/nsswitch.conf'
  bh_env_add "LANG" "en_US.UTF-8"
}

# ---------------------------------------
# choco
# ---------------------------------------

function bh_choco_install() {
  Invoke-Expression $bh_log_func
  if (!(Get-Command 'gsudo.exe' -ea 0)) {
    bh_install_gsudo
  }
  $pkgs_to_install = ""
  $pkgs = $(choco list -l | ForEach-Object { $_.split(' ')[0] }) -join (" ")
  foreach ($name in $args) {
    if (-not ($pkgs.Contains("$name"))) {
      $pkgs_to_install += "$name $pkgs_to_install"
    }
  }
  if ($pkgs_to_install) {
    bh_log "pkgs_to_install=$pkgs_to_install"
    gsudo choco install -y --acceptlicense ($pkgs_to_install -join ";")
  }
}

# ---------------------------------------
# install
# ---------------------------------------

function bh_install_choco() {
  if (!(Get-Command 'choco.exe' -ea 0)) {
    Invoke-Expression $bh_log_func
    if (!(bh_user_is_admin)) { bh_log "not admin."; return; }
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    bh_path_add "%ALLUSERSPROFILE%\chocolatey\bin"
    cmd /c 'setx ChocolateyToolsLocation C:\opt\'
    $chocotools = [Environment]::GetEnvironmentVariable('ChocolateyToolsLocation')
    bh_path_add $chocotools

    choco feature disable -n checksumFiles
    choco feature disable -n showDownloadProgress
    choco feature disable -n showNonElevatedWarnings
    choco feature disable -n logValidationResultsOnWarnings
    choco feature disable -n logEnvironmentValues
    choco feature disable -n exitOnRebootDetected
    choco feature disable -n warnOnUpcomingLicenseExpiration
    choco feature enable -n stopOnFirstPackageFailure
    choco feature enable -n skipPackageUpgradesWhenNotInstalled
    choco feature enable -n logWithoutColor
    choco feature enable -n allowEmptyChecksumsSecure
    choco feature enable -n allowGlobalConfirmation
    choco feature enable -n failOnAutoUninstaller
    choco feature enable -n removePackageInformationOnUninstall
    choco feature enable -n useRememberedArgumentsForUpgrades
    # enable use without restarting Powershell
    refreshenv
  }
}

function bh_install_texlive() {
  if (-not (Test-Path "C:\texlive")) {
    Invoke-Expression $bh_log_func
    if (!(bh_user_is_admin)) { bh_log "not admin."; return; }
    hf_choco_install texlive
  }
}

function bh_install_msys() {
  if (-not (Test-Path $MSYS_HOME)) {
    Invoke-Expression $bh_log_func
    if (!(bh_user_is_admin)) { bh_log "not admin."; return; }
    winget install --scope=machine msys2.msys2
    bh_msys_add_to_path
  }
}

function bh_install_gsudo() {
  if (!(Get-Command 'gsudo.exe' -ea 0)) {
    Invoke-Expression $bh_log_func
    if (!(bh_user_is_admin)) { bh_log "not admin."; return; }
    winget install --scope=machine gsudo
    bh_path_add 'C:\Program Files (x86)\gsudo'
  }
}

function bh_install_wsl_ubuntu() {
  # this helper automate the process describred in :
  # - https://docs.microsoft.com/en-us/windows/wsl/wsl2-install
  # - https://ubuntu.com/wsl
  Invoke-Expression $bh_log_func
  if (!(bh_user_is_admin)) { bh_log "not admin."; return; }

  # install winget
  if (!(Get-Command "winget.exe" -ea 0)) {
    bh_log "INFO: winget is not installed, installing..."
    Get-AppxPackage Microsoft.DesktopAppInstaller | ForEach-Object { Add-AppxPackage -ea 0 -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" } | Out-null
  } 
  # enable wsl feature (require restart)
  if (!(Get-Command 'wsl.exe' -ea 0)) {
    bh_log "INFO: Windows features for WSL not enabled, enabling..."
    bh_feature_enable /featurename:VirtualMachinePlatform 
    bh_feature_enable Microsoft-Windows-Subsystem-Linux
    bh_log "INFO: restart windows and run bh_setup_ubuntu again"
    return
  }
  # install ubuntu
  if (!(Get-Command "ubuntu*.exe" -ea 0)) {
    bh_log "INFO: Ubuntu is not installed, installing..."
    winget install Canonical.Ubuntu
  } 
  # configure ubuntu distro
  wsl -l | Out-null
  if ($LastExitCode -eq -1) {
    bh_log "INFO: Ubuntu is not configured, running it..."
    bh_log "INFO: You should configure username and passwd, after that exit Ubuntu by invoke 'exit'."
    Invoke-Expression (Get-Command "ubuntu*.exe").Source
  }
  # enable wsl 2
  wsl -l -v | Out-null # -v is only avaliable in wsl 2
  if ($LastExitCode -eq -1) {
    bh_log "INFO: WSL 2 kernel update is not installed, installing..."
    Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -Outfile $env:TEMP\wsl_update_x64.msi
    msiexec.exe /I "$env:TEMP\wsl_update_x64.msi"
  }
  # set to version 2
  if ((bh_wsl_get_default_version) -eq 1) {
    bh_log "INFO: Ubuntu distro is in wsl version 1, converting it to version 2..."
    bh_wsl_set_version2 bh_wsl_get_default
  }
  # fix home user to \Users
  if (!(wsl echo '$HOME').Contains("Users")) {
    bh_log "INFO: Configuring to same home folder as windows..."
    bh_wsl_fix_home
  }
}

# ---------------------------------------
# optmize
# ---------------------------------------

function bh_optimize_explorer() {
  # Remove * from This PC
  # ----------------------------------------
  bh_log "Remove user folders under This PC "
  # Remove Desktop from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -ea 0
  # Remove Documents from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" -ea 0
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" -ea 0
  # Remove Downloads from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" -ea 0
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" -ea 0
  # Remove Music from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -ea 0
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -ea 0
  # Remove Pictures from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" -ea 0
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" -ea 0
  # Remove Videos from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -ea 0
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -ea 0
  # Remove 3D Objects from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -ea 0
  
  # Set explorer how file extensions
  bh_log "Set explorer show file extensions"
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -Value 0

  # 'Share with'
  # ----------------------------------------
  bh_log "Share with"
  Remove-Item -LiteralPath "HKCR:\*\shellex\ContextMenuHandlers\Sharing" -ea 0
  Remove-Item -Path "HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing" -ea 0
  Remove-Item -Path "HKCR:\Directory\shellex\ContextMenuHandlers\Sharing" -ea 0
  Remove-Item -Path "HKCR:\Drive\shellex\ContextMenuHandlers\Sharing" -ea 0
  # for gitg
  bh_log "gitg"
  Remove-Item "HKCR:\Directory\shell\gitg" -Recurse -ea 0
  # for add/play with vlc
  bh_log "Add/play with vlc"
  Remove-Item "HKCR:\Directory\shell\AddToPlaylistVLC" -Recurse -ea 0
  Remove-Item "HKCR:\Directory\shell\PlayWithVLC" -Recurse -ea 0
  # for git bash
  bh_log "Git bash"
  Remove-Item "HKCR:\Directory\shell\git_gui" -Recurse -ea 0
  Remove-Item "HKCR:\Directory\shell\git_shell" -Recurse -ea 0
  # "Open With"
  bh_log "Open With "
  Remove-Item -LiteralPath 'HKCR:\*\shellex\OpenWithList' -ea 0
  # Pin To Start
  bh_log "Pin To Start "
  Remove-Item -LiteralPath 'HKCR:\*\shellex\ContextMenuHandlers\{90AA3A4E-1CBA-4233-B8BB-535773D48449}' -ea 0
  Remove-Item -LiteralPath 'HKCR:\*\shellex\ContextMenuHandlers\{a2a9545d-a0c2-42b4-9708-a0b2badd77c8}' -ea 0
  Remove-Item 'HKCR:\Folder\shellex\ContextMenuHandlers\PintoStartScreen' -ea 0
  # 'Include in library'
  bh_log "Include in library"
  Remove-Item "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location" -ea 0
  Remove-Item "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location" -ea 0
  # 'Send to'
  bh_log "Send to"
  Remove-Item -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo" -Recurse -ea 0
  
  # create some regs
  # ------------------
  bh_reg_new_path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
  bh_reg_new_path "HKLM:\Software\Policies\Microsoft\Windows\Explorer"
  
  # 'Hide Recently used Apps in Start Menu'
  bh_log 'Hide Recently used Apps in Start Menu'
  Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\Explorer' -Name 'HideRecentlyAddedApps' -Value 1

  # Disable file delete confirmation dialog
  bh_log "Disable file delete confirmation dialog"
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -Value 0
  
  # Disable action center
  bh_log "Hide action center button "
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "DisableNotificationCenter" -Value 1
  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Value 1
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Value 0
  
  # restart explorer
  Stop-Process -ProcessName explorer
}

function bh_optimize_windows() {
  Invoke-Expression $bh_log_func
  if (!(bh_user_is_admin)) { bh_log "not admin."; return; }

  # Remove Lock screen
  bh_log "Remove Lockscreen "
  bh_reg_new_path "HKLM:\Software\Policies\Microsoft\Windows\Personalization"
  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Value 1
  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "DisableLogonBackgroundImage" -Value 1

  # Disable drives Autoplay
  bh_log "Disable new drives Autoplay"
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 1

  # Disable offering of Malicious Software Removal Tool through Windows Update
  bh_log "Disable Malicious Software Removal Tool offering"
  New-Item -Path "HKLM:\Software\Policies\Microsoft\MRT" -ea 0
  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Value 1

  # Disable Remote Assistance
  bh_log "Disable Remote Assistance"
  Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Value 0

  # Disable Autorun for all drives
  bh_log "Disable Autorun for all drives"
  bh_reg_new_path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
  Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Value 255

  # Disable error reporting
  bh_log "Disable error reporting "
  reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKLM\Software\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f | Out-Null

  # Disable license checking
  bh_log "Disable license checking "
  reg add "HKLM\Software\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v NoGenTicket /t REG_DWORD /d 1 /f | Out-Null

  # Disable tips
  bh_log "Disable tips "
  reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableSoftLanding /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightFeatures /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\Windows\DataCollection" /v DoNotShowFeedbackNotifications /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\WindowsInkWorkspace" /v AllowSuggestedAppsInWindowsInkWorkspace /t REG_DWORD /d 0 /f | Out-Null

  # 'Disable Accessibility Keys Prompts
  bh_log 'Disable Accessibility Keys Prompts '
  $path = 'HKCU:\Control Panel\Accessibility\'
  Set-ItemProperty -Path "$path\StickyKeys" -Name 'Flags' -Type String -Value '506'
  Set-ItemProperty -Path "$path\ToggleKeys" -Name 'Flags' -Type String -Value '58'
  Set-ItemProperty -Path "$path\Keyboard Response" -Name 'Flags' -Type String -Value '122'

  # "Disable Windows Timeline
  bh_log "Disable Windows Timeline "
  Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\System' -Name 'EnableActivityFeed' -Value 0

  # Disable Bing
  bh_log "Disable Bing search "
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /d "0" /t REG_DWORD /f  | Out-null
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v AllowSearchToUseLocation /d "0" /t REG_DWORD /f | Out-null
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /d "0" /t REG_DWORD /f | Out-null
  reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Search" /v ConnectedSearchUseWeb /d "0" /t REG_DWORD /f | Out-null
  
  # Disable Cortana
  bh_log "Disable Cortana"

  bh_reg_new_path "HKCU:\Software\Microsoft\Personalization\Settings"
  bh_reg_new_path "HKCU:\Software\Microsoft\InputPersonalization"
  bh_reg_new_path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore"
  bh_reg_new_path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search"

  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Value 0
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Value 1
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Value 1
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Value 0
  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0

  # disable beep
  net stop beep
  
  # Disable Windows Defender'
  bh_log "Windows Defender "
  Set-Item "HKCR:\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32" "" -ea 0
  
  # Disable unused services
  bh_log "Disable unused services "
  $services = @("*diagnosticshub.standardcollector.service*" # Diagnostics Hub
    "*diagsvc*" # Diagnostic Execution Service
    "*dmwappushservice*" # Device Management WAP Push message Routing Service
    "*DiagTrack*" # Connected User Experiences and Telemetry
    "*lfsvc*" # Geolocation Service
    "*MapsBroker*" # Downloaded Maps Manager
    "*RetailDemo*" # Retail Demo Service
    "*RemoteRegistry*" # Remote Registry
    "*FoxitReaderUpdateService*" # Remote Registry
    "*RemoteAccess*" # Routing and Remote Access (routing services to businesses in LAN)
    "*TrkWks*" # Distributed Link Tracking Client
    "*XblAuthManager*" # Xbox Live Auth Manager
    "*XboxNetApiSvc*" # Xbox Live Networking Service
    "*XblGameSave*" # Xbox Live Game Save
    "*wisvc*" # Windows Insider Service
  )
  bh_service_disable $services

  # XPS Services
  bh_log "Disable XPS "
  bh_feature_disable Printing-XPSServices-Features

  # Work Folders
  bh_log "Disable Work Folders "
  bh_feature_disable WorkFolders-Client
  
  # Disable scheduled tasks
  bh_log "Disable scheduled tasks "
  $tasks = @(
    'CCleaner Update'
    'CCleanerSkipUAC'
  )
  bh_scheduledtask_disable @tasks
}

function bh_optimize_password_policy {
  _disabled
  Invoke-Expression $bh_log_func
  $tmpfile = New-TemporaryFile
  secedit /export /cfg $tmpfile /quiet
  (Get-Content $tmpfile).Replace("PasswordComplexity = 1", "PasswordComplexity = 0").Replace("MaximumPasswordAge = 42", "MaximumPasswordAge = -1") | Out-File $tmpfile
  secedit /configure /db "$env:SYSTEMROOT\security\database\local.sdb" /cfg $tmpfile /areas SECURITYPOLICY | Out-Null
  Remove-Item -Path $tmpfile
}

function bh_setup_win_admin() {
  Invoke-Expression $bh_log_func
  if (!(bh_user_is_admin)) { bh_log "not admin."; return; }
  bh_install_choco
  bh_install_gsudo
  bh_optimize_password_policy_disabled
  bh_optimize_windows
  bh_optimize_explorer
}