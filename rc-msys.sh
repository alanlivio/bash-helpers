# ---------------------------------------
# update_clean
# ---------------------------------------

function bh_update_cleanup_msys() {
  bh_log_func
  # windows
  if [ "$(bh_win_user_check_admin)" == "True" ]; then
    bh_win_sysupdate_win
  fi
  # essentials
  local pkgs="pacman pacman-mirrors msys2-runtime vim diffutils curl $BH_PKGS_MSYS"
  # python
  pkgs+="python-pip "
  bh_msys_install $pkgs
  bh_msys_upgrade
  # python
  $HAS_PYTHON && bh_python_install $BH_PKGS_PYTHON
  # cleanup
  bh_home_clean_unused
}
