#########################
# essentials aliases
#########################
alias ls='ls --color=auto -I NTUSER\* -I ntuser\* -I AppData -I IntelGraphicsProfiles* -I MicrosoftEdgeBackups'
alias winget='winget.exe'
alias powershell='powershell.exe'
BH_PS1_DIR="$BH_DIR/lib/ps1/"

#########################
# explorer open
#########################
function explorer_hide_home_dotfiles() { powershell -c 'Get-ChildItem "${env:userprofile}\\.*" | ForEach-Object { $_.Attributes += "Hidden" }'; }
function explorer_restart() { powershell "Stop-Process -ProcessName explorer -ea 0 | Out-Null"; }
function explorer_open_startmenu() { powershell -c 'explorer ${env:appdata}\Microsoft\Windows\Start Menu\Programs'; }
function explorer_open_startmenu_all_users() { powershell -c 'explorer ${env:programdata}\Microsoft\Windows\Start Menu\Programs'; }
function explorer_open_recycle_bin() { powershell -c 'explorer shell:RecycleBinFolder'; }

#########################
# win upgrade
#########################

function win_upgrade() {
  gsudo powershell.exe -c 'Install-Module -Name PSWindowsUpdate -Force; Install-WindowsUpdate -AcceptAll -IgnoreReboot'
}

#########################
# regedit
#########################

function regedit_open_path() {
  powershell -c "
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\ /v Lastkey /d 'Computer\\$1' /t REG_SZ /f
    regedit.exe
  "
}

function regedit_open_shell_folders() {
  regedit_open_path 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
}

#########################
# env & path
#########################

function win_env_show() {
  powershell -c '[System.Environment]::GetEnvironmentVariables()'
}

function win_env_add() {
  : ${2?"Usage: ${FUNCNAME[0]} <varname> <value>"}
  powershell -c "[System.Environment]::SetEnvironmentVariable('$1', '$2', 'user')"
}

function win_path_show() {
  powershell -c '(Get-ChildItem Env:Path).Value'
}

function win_path_show_as_list() {
  IFS=';' read -ra ADDR <<<$(win_path_show)
  for i in "${!ADDR[@]}"; do echo ${ADDR[$i]}; done
}

function win_path_add() { # using ps1 script
  local dir=$(cygpath -w $@)
  local dircyg=$(cygpath $@)
  # export in win
  powershell -c "$(cygpath -w $BH_PS1_DIR/path_add.ps1)" \'$dir\'
  # export in bash (it will reolad from win in new shell)
  if [[ ":$PATH:" != *":$dircyg:"* ]]; then export PATH=${PATH}:$dircyg; fi
}

#########################
# winget
#########################

function winget_show_with_versions() {
  winget show --versions $1
}

function winget_upgrade_all() {
  winget upgrade --all --silent
}

function winget_install() {
  local pkgs_to_install=""
  for i in "$@"; do
    if [[ $(winget list --id $i) =~ "No installed"* ]]; then
      pkgs_to_install="$i $pkgs_to_install"
    fi
  done
  if test ! -z "$pkgs_to_install"; then
    echo "pkgs_to_install=$pkgs_to_install"
    for pkg in $pkgs_to_install; do
      winget install --accept-package-agreements --accept-source-agreements --silent $pkg
    done
  fi
}

#########################
# services
#########################

function services_reset_startup() { gsudo powershell.exe \'$(cygpath -w $BH_PS1_DIR/services_reset_startup.ps1)\'; }
function services_disable_unused() { gsudo powershell.exe \'$(cygpath -w $BH_PS1_DIR/services_disable_unused.ps1)\'; }

#########################
# sanity
#########################

function win_sanity_ctx_menu() { gsudo powershell.exe \'$(cygpath -w $BH_PS1_DIR/sanity_ctx_menu.ps1)\'; }
function win_sanity_password_policy() { gsudo powershell.exe \'$(cygpath -w $BH_PS1_DIR/sanity_password_policy.ps1)\'; }
function win_sanity_this_pc() { gsudo powershell.exe \'$(cygpath -w $BH_PS1_DIR/sanity_this_pc.ps1)\'; }
function win_sanity_ui() { gsudo powershell.exe \'$(cygpath -w $BH_PS1_DIR/sanity_ui.ps1)\'; }

#########################
# msys2
#########################

alias msys2_search='pacman -s --noconfirm'
alias msys2_show='pacman -Qi'
alias msys2_list_installed='pacman -Qqe'
alias msys2_install='pacman -S --noconfirm'
alias msys2_uninstall='pacman -R --noconfirm'
alias msys2_use_same_home='echo db_home: windows >>/etc/nsswitch.conf'

#########################
# wsl
#########################

function win_install_wsl() { gsudo powershell.exe \'$(cygpath -w $BH_PS1_DIR/wsl_install.ps1)\'; }
function wsl_use_same_home() { gsudo powershell.exe \'$(cygpath -w $BH_PS1_DIR/wsl_use_same_home.ps1)\'; }
function wsl_code_from_win() {
  if [ "$#" -ne 0 ]; then
    powershell -c '& code ' "$@";
  else
    powershell -c '& code .';
  fi
}
