#!/bin/bash

# ---------------------------------------
# gitbash aliases
# ---------------------------------------

alias unixpath='cygpath'
alias winpath='cygpath -w'
# fix mingw tmp
unset temp
unset tmp
# hide windows user files when ls home
alias ls='ls --color=auto --hide=ntuser* --hide=NTUSER* --hide=AppData --hide=IntelGraphicsProfiles* --hide=MicrosoftEdgeBackups'
alias chrome="/c/Program\ Files/Google/Chrome/Application/chrome.exe"
alias whereis='where'
alias reboot='gsudo shutdown \/r'
alias ps_call="powershell.exe -c"
alias ps_call_admin="gsudo powershell.exe -c"

function bh_open {
  local node="${1:-.}" # . is default value
  ps_call "Start-Process $node"
}

function bh_open_wt_settings() {
  bh_wt_stgs="$HOME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
  code $bh_wt_stgs
}

function ps_call_script() {
  powershell.exe -c "& { . $1}"
}

function ps_call_script_admin() {
  gsudo powershell.exe -c "& { . $1}"
}

# ---------------------------------------
# load commands
# ---------------------------------------

source "$BH_DIR/win/user.sh"
source "$BH_DIR/win/install.sh"
source "$BH_DIR/win/winget.sh"
source "$BH_DIR/win/explorer.sh"
if type gsudo &>/dev/null; then source "$BH_DIR/win/admin.sh"; fi

function bh_win_sanity() {
  powershell.exe -command "& { . $(unixpath -w $BH_DIR/win/win-sanity.ps1) }"
}

# ---------------------------------------
# update_clean
# ---------------------------------------

function bh_update_cleanup_win() {
  # cleanup
  bh_home_clean_unused
  bh_explorer_hide_home_dotfiles
  # winget (it uses --scope=user)
  bh_win_get_install $BH_PKGS_WINGET
  # python
  type pip &>/dev/null && bh_python_install $BH_PKGS_PYTHON
  # vscode
  type code &>/dev/null && bh_vscode_install $BH_PKGS_VSCODE
  # windows
  type gsudo &>/dev/null && bh_win_sysupdate_win
}
