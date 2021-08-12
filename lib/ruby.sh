function bh_ruby_install() {
  bh_log_func
  bh_test_noargs_then_return

  local pkgs_to_install=""
  local pkgs_installed=$(gem list | cut -d' ' -f1 -s | tr '\n' ' ')
  for i in "$@"; do
    found=false
    for j in $pkgs_installed; do
      if test $i == $j; then
        found=true
        break
      fi
    done
    if ! $found; then pkgs_to_install="$pkgs_to_install $i"; fi
  done
  if test ! -z "$pkgs_to_install"; then
    echo "pkgs_to_install=$pkgs_to_install"
    sudo gem install $pkgs_to_install
    if test "$(pwd)" == "/tmp"; then cd - >/dev/null; fi
  fi
}