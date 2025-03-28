#!/system/bin/sh
setprop sys.usb.config none
stop adbd
sleep 1
setprop sys.usb.config adb
setprop sys.usb.state adb
start adbd
