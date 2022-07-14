alias adbip="adb shell netcfg && adb shell ifconfig wlan0"
alias adbscreencp="adb shell /system/bin/screencap -p /sdcard/screenshot.png && adb pull /sdcard/screenshot.png screenshot.png" # capture as screeshot.png
alias adbstart="adb shell am start -a android.intent.action.MAIN -n"    # start activity X.Y.Z/.K
alias adbstop="adb shell am stop -a android.intent.action.MAIN -n"      # stop activity X.Y.Z/.K
alias adbl="adb shell pm list packages"
alias adbl3="adb shell pm list packages -3"
alias adbls="adb shell pm list packages -s"
alias adbps="adb shell ps | grep ^u | awk '{print \$9}'"
alias adbk="adb shell am kill"                                          # kill pkg X.Y.Z
alias adbi="adb shell pm install -k --user 0 "                          # uninstall pkg X.Y.Z
alias adbu="adb shell pm uninstall -k --user 0 "                        # uninstall pkg X.Y.Z
