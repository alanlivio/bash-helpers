# pacman
alias msys2_search='pacman -Ss --noconfirm'
alias msys2_show='pacman -Qi'
alias msys2_list_installed='pacman -Qqe'
alias msys2_install='pacman -Su --needed --noconfirm'
alias msys2_install_force='pacman -Syu --noconfirm'
alias msys2_uninstall='pacman -R --noconfirm'

function msys_use_same_home() {
  if ! test -d /mnt/; then mkdir /mnt/; fi
  echo -e "none / cygdrive binary,posix=0,noacl,user 0 0" | tee /etc/fstab
  echo -e "C:/Users /home ntfs binary,noacl,auto 1 1" | tee -a /etc/fstab
  echo -e "C:/Users /Users ntfs binary,noacl,auto 1 1" | tee -a /etc/fstab
  # use /mnt/c/ like in WSL
  echo -e "/c /mnt/c none bind" | tee -a /etc/fstab
  echo -e 'db_home: windows >> /etc/nsswitch.conf' | tee -a /etc/nsswitch.conf
}