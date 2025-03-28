#!/system/bin/sh
# TGDK Snelleus Self-Recognition Bridge

echo "[SELF-BIND] Forcing self-recognition via internal USB stack..."

# Step 1: Stop ADB daemon
setprop sys.usb.config none
stop adbd
sleep 1

# Step 2: Reset USB and rebind ADB config
setprop sys.usb.config adb
setprop sys.usb.state adb
start adbd
sleep 1

# Step 3: Verify loopback ADB state
echo "[SELF-BIND] Verifying system properties:"
getprop sys.usb.config
getprop sys.usb.state

# Step 4: Show active ADB interface
echo "[SELF-BIND] Checking internal ADB registration:"
ps | grep adbd