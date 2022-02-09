<h1 align="center"><img src="docs/logo.svg" width="250" onerror='this.style.display="none"'/></h1>

# bash-helpers

Bash helpers to install software (wsl/msys, adb, flutter, ffmpeg), configure OS (dark mode, clean taskbar/clutter), update python/vscode pkgs, clean unused folders, sync dotfiles, common git calls, and more. 
The project logo refers to the synthetic chemical element Bohrium, which also has the initials bh.

## Install

The bash-helpers has two requirements: a `bash shell` and `git`. Particulary on windows, they can be installed using [GitForWindows](https://gitforwindows.org/) (you may install it running [install-gitforwindows-and-wt.ps1](https://github.com/alanlivio/bash-helpers/blob/master/lib/win/install-gitforwindows-and-wt.ps1) on powershell). 

on ubuntu/macOS/GitForWindows `bash shell` with git, run:
```bash
  git clone https://github.com/alanlivio/bash-helpers ~/.bh &&\
    echo "source ~/.bh/init.sh" >> ~/.bashrc &&\
    source ~/.bashrc
```

## helpers

### configure OS interface helpers

* `bh_ubu_gnome_sanity` (at ubuntu bash): enable dark mode, disable animations, clean taskbar (e.g. small icons), uninstall pre-installed and not used apps (e.g. weather, news, calendar, solitaire)
* `bh_win_sanity` (at gitbash): enable dark mode, disable animations, clean taskbar (e.g. small icons)
* `bh_mac_sanity` (at bash): TODO

### install software helpers

* `bh_win_install_msys` (at windows GitBash): to install msys (Cygwin-based) with bash to build GNU-based win32 applications
* `bh_win_install_wsl` (at windows GitBash): to install WSL/Ubuntu (version 2, fixed home). This helper automates the process described in [Microsoft WSL Tutorial](https://docs.microsoft.com/en-us/windows/wsl/wsl2-install). After running it, it requires restarting windows and running it again. When the Ubuntu app starts, you need to configure your username/password.
* See others `bh_win_install_*` at ./lib/win/
* See others `bh_ubu_install_*` at ./lib/ubu/

### update/cleanup helpers

The helpers bellow can be run routinely. They install packages defined in `BH_PKGS_*` vars at `~/.bhrc.sh` (or `~/.bashrc`), and also clean unused files/folders defined in `BH_HOME_CLEAN_UNUSED` var. Please see the vars examples in [skel/.bhrc.sh](https://github.com/alanlivio/bash-helpers/blob/master/skel/.bhrc.sh).

* `bh_update_cleanup_mac` (at mac bash): BH_PKGS_BREW, BH_PKGS_PY, BH_PKGS_VSCODE
* `bh_update_cleanup_ubu` (at ubuntu bash): BH_PKGS_APT_UBU, BH_PKGS_PY, BH_PKGS_VSCODE, BH_PKGS_SNAP, BH_PKGS_SNAP_CLASSIC
* `bh_update_cleanup_win` (at GitBash): BH_PKGS_WINGET, BH_PKGS_PY, BH_PKGS_VSCODE
* `bh_update_cleanup_wsl` (at WSL bash): BH_PKGS_APT_WSL, BH_PKGS_PY_WSL
* `bh_update_cleanup_msys` (at msys bash): BH_PKGS_MSYS, BH_PKGS_PY_MSYS

### dotfiles/home managment helpers

* `bh_dotfiles_backup`: backup files/dirs defined in BH_DOTFILES_BKPS
* `bh_dotfiles_diff`: show diff files/dirs defined in BH_DOTFILES_BKPS
* `bh_dotfiles_install`: restore files/dirs defined in BH_DOTFILES_BKPS
* `bh_home_clean_unused`: clean files/dirs defined in array BH_HOME_CLEAN_UNUSED
* `bh_dev_folder_git_repos`: clone/update git repos defined in BH_DEV_REPOS

### curl helpers

* `bh_curl_get`: GET request to URL
* `bh_curl_post`: POST request to URL
* `bh_curl_post_json`: POST request to URL using JSON
* `bh_curl_fetch_to_dir`: get URL to parent dir

### forder helpers

* `bh_folder_sorted_by_size`: list folder sorted by items size
* `bh_folder_info`: list number of folder and files per extension
* `bh_folder_find_duplicated_pdf`: list duplicated pdf files in folder recursively

### others helpers

The helpers below are for cross plataform commands. For the full list, see lib/ folder.

* `bh_adb_*`: adb helpers.
* `bh_cmake_*`: cmake helpers.
* `bh_docker_*`: docker helpers.
* `bh_ffmpeg_*`: ffmpeg helpers.
* `bh_flutter_*`: flutter helpers.
* `bh_gcc_*`: gcc helpers.
* `bh_git_*`: git helpers.
* `bh_ghostscript_*`: ghostscript helpers (for pdf).
* `bh_meson_*`: meson helpers.
* `bh_npm_*`: npm helpers.
* `bh_pandoc_*`: pandoc helpers.
* `bh_pdflatex_*`: pdflatex helpers.
* `bh_pkg-config_*`: pkg-config helpers.
* `bh_py_*`: python helpers.
* `bh_ruby_*`: ruby helpers.
* `bh_ssh_*`: ssh helpers.
* `bh_tesseract_*`: tesseract helpers.
* `bh_vscode_*`: vscode helpers.
* `bh_wget_*`: wget helpers.
* `bh_youtubedl_*`: youtube-dl helpers.
* `bh_zip_*`: zip helpers.

## References

The projects bellow used as reference:

* <https://github.com/milianw/shell-helpers>
* <https://github.com/wd5gnr/bashrc>
* <https://github.com/martinburger/bash-common-helpers>
* <https://github.com/jonathantneal/git-bash-helpers>
* <https://github.com/Bash-it/bash-it>
* <https://github.com/donnemartin/dev-setup>
* <https://github.com/aspiers/shell-env>

And, particulary, these were reference for helpers on windows:

* <https://github.com/adolfintel/windows10-Privacy>
* <https://gist.github.com/alirobe/7f3b34ad89a159e6daa1>
* <https://github.com/RanzigeButter/fyWin10/blob/master/fyWin10.ps1>
* <https://github.com/madbomb122/Win10Script/blob/master/Win10-Menu.ps1>
* <https://github.com/Sycnex/windows10Debloater/blob/master/windows10Debloater.ps1>
* <https://github.com/W4RH4WK/Debloat-windows-10/tree/master/scripts>
