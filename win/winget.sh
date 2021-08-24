# ---------------------------------------
# winget
# ---------------------------------------

function bh_winget_list_installed() {
  winget list
}

function bh_winget_list_installed_str() {
  powershell -c '
    $tmpfile = New-TemporaryFile
    winget export $tmpfile | Out-null
    $pkgs = ((Get-Content $tmpfile | ConvertFrom-Json).Sources.Packages | ForEach-Object { $_.PackageIdentifier }) -join " "
    echo $pkgs
  '
}

function bh_winget_install() {
  bh_log_func
  local pkgs_to_install=""
  local pkgs_installed=$(bh_winget_list_installed_str)
  for i in "$@"; do
    if [[ $i != "" && $pkgs_installed =~ $i ]]; then
      pkgs_to_install="$i $pkgs_to_install"
    fi
  done
  if test ! -z "$pkgs_to_install"; then
    echo "pkgs_to_install=$pkgs_to_install"
    for pkg in $pkgs_to_install; do
      winget install $pkg &>/dev/null
    done
  fi
}

function bh_winget_settings() {
  winget settings
}

function bh_winget_upgrade() {
  winget upgrade --all --silent
}