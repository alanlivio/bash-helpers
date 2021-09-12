# ---------------------------------------
# install non-admin
# ---------------------------------------

function bh_install_win_python() {
  if ! type pip &>/dev/null; then
    powershell.exe -c "& { . $(unixpath -w $BH_DIR/win/admin/install-python.ps1) }"
  fi
}

function bh_install_win_vscode() {
  if ! type code &>/dev/null; then
    hf_winget_install vscode
  fi
}

function bh_install_win_miktex() {
  if ! type miktex-pdflatex.exe &>/dev/null; then
    hf_winget_install MiKTeX
  fi
}

function bh_install_win_make() {
  local url="https://jztkft.dl.sourceforge.net/project/ezwinports/make-4.3-without-guile-w32-bin.zip"
  local dir="$BH_OPT_WIN/make-4.3-without-guile-w32-bin"
  if ! test -d $dir; then
    bh_test_and_create_folder $dir
    bh_decompress_from_url $url $dir # no root folder
    if test $? != 0; then bh_log_error "bh_decompress_from_url failed." && return 1; fi
    bh_path_win_add $(winpath $dir/bin)
  fi
}

BH_NODE_VER="14.17.5"
function bh_install_win_node() {
  local url="https://nodejs.org/dist/v${BH_NODE_VER}/node-v${BH_NODE_VER}-win-x64.zip"
  local dir="$BH_OPT_WIN/node-v${BH_NODE_VER}-win-x64"
  if ! test -d $dir; then
    bh_test_and_create_folder $dir
    bh_decompress_from_url $url $BH_OPT_WIN
    if test $? != 0; then bh_log_error "bh_decompress_from_url failed." && return 1; fi
    bh_env_win_add 'NODEJS_HOME' $(winpath $dir)
    bh_path_win_add $(winpath $dir)
  fi
}

BH_FLUTTER_VER="2.2.3"
BH_ANDROID_CMD_VER="7583922"
function bh_install_win_androidcmd_flutter() {
  bh_log_func

  # create opt
  local opt_dst="$BH_OPT_WIN"
  bh_test_and_create_folder $opt_dst

  # android cmd and sdk
  local android_sdk_dir="$opt_dst/android"
  local android_cmd_dir="$android_sdk_dir/cmdline-tools"
  local android_cmd_url="https://dl.google.com/android/repository/commandlinetools-win-${BH_ANDROID_CMD_VER}_latest.zip"
  if ! test -d $android_cmd_dir; then
    bh_decompress_from_url $android_cmd_url $android_sdk_dir
    if test $? != 0; then bh_log_error "bh_decompress_from_url failed." && return 1; fi
    bh_path_win_add $(winpath $android_cmd_dir/bin)
  fi
  if ! test -d $android_sdk_dir/platforms; then
    $android_cmd_dir/bin/sdkmanager.bat --sdk_root="$android_sdk_dir" --install 'platform-tools' 'platforms;android-29'
    yes | $android_cmd_dir/bin/sdkmanager.bat --sdk_root="$android_sdk_dir" --licenses
    bh_env_win_add ANDROID_HOME $(winpath $android_sdk_dir)
    bh_env_win_add ANDROID_SDK_ROOT $(winpath $android_sdk_dir)
    bh_path_win_add $(winpath $android_sdk_dir/platform-tools)
  fi

  # flutter
  local flutter_sdk_dir="$opt_dst/flutter"
  local flutter_sdk_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_${BH_FLUTTER_VER}-stable.zip"
  if ! test -d $flutter_sdk_dir; then
    # opt_dst beacuase zip extract the flutter dir
    bh_decompress_from_url $flutter_sdk_url $opt_dst
    if test $? != 0; then bh_log_error "bh_decompress_from_url failed." && return 1; fi
    bh_path_win_add $(winpath $flutter_sdk_dir/bin)
  fi
}

function bh_install_win_latexindent() {
  bh_log_func
  if ! type latexindent.exe &>/dev/null; then
    bh_curl_fetch_to_dir https://github.com/cmhughes/latexindent.pl/releases/download/V3.10/latexindent.exe $BH_OPT_WIN
    bh_curl_fetch_to_dir https://raw.githubusercontent.com/cmhughes/latexindent.pl/main/defaultSettings.yaml $BH_OPT_WIN
    bh_path_win_add $BH_OPT_WIN
  fi
}
