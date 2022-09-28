alias apt_upgrade="sudo apt -y update; sudo apt -y upgrade"
alias apt_update="sudo apt -y update"
alias apt_ppa_remove="sudo add-apt-repository --remove"
alias apt_ppa_list="apt policy"
alias apt_install="sudo apt install -y"
alias apt_autoremove="sudo apt -y autoremove"
alias apt_clean=apt_autoremove
alias apt_uninstall="sudo apt remove -y --purge "
function apt_fixes() {
  sudo dpkg --configure -a
  sudo apt install -f --fix-broken
  sudo apt-get update --fix-missing
  sudo apt dist-upgrade
}