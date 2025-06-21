#!/bin/bash
# =============================================================
# TGDK - root_vortex.sh
# Phase 0 Entropy Pulse to Trigger ADB Recognition
# Licensed: D2501-V01 | Operator: Sean Tichenor
# =============================================================

echo "[ROOT_VORTEX] Initializing sacrificial wake pulse..."
sleep 0.4

device_model=$(adb shell getprop ro.product.model)
echo "[INFO] Detected device: $device_model"

logfile="/tmp/root_vortex_log_$(date +%s).log"
echo "[LOG] Session start: $(date)" >> $logfile

# Step 1: Simulate entropy emission
echo "[ENTROPY] Emitting QQUAp-coded entropy for ADB bait..."
for i in {1..4}; do
  echo "QQUAp-SEED-${RANDOM}${RANDOM}" >> /dev/null
  sleep 0.25
done

echo "[QQUAp] Emitting encoded sigil..."
for i in {1..4}; do
  echo -n "SIGIL-$(openssl rand -hex 4)" | sha256sum >> /dev/null
  sleep 0.25
done

usb_path=$(find /sys/bus/usb/devices/ -name "authorized" | head -n1)
echo 0 > "$usb_path"
sleep 1
echo 1 > "$usb_path"

# Step 2: Trigger ADB probing
echo "[ADB] Pinging ADB device state..."
adb start-server
adb devices
adb wait-for-device

# Step 3: Simulated logcat injection (acts as captor-bait)
echo "[ADB] Triggering synthetic logcat scan..."
adb logcat -d | grep -i "boot" | head -n 1

# Step 4: Sacrifice event — notify system
echo "[ROOT_VORTEX] Sacrificial trigger acknowledged."
echo "[TGDK] Device primed for root sequence."

# Step 5: Optional USB detach/attach logic
echo 0 > /sys/bus/usb/devices/1-1/authorized
sleep 1
echo 1 > /sys/bus/usb/devices/1-1/authorized

# Step 6: Final check
adb wait-for-device && echo "[✓] ADB connection stabilized."

# Trigger root chain
echo "[ROOT_VORTEX] Executing TGDK Root Bridge..."
./adb_device_link.sh
