#!/bin/bash
# ====================================================================
# TGDK ADB DEVICE LINK SCRIPT - D2501-V01
# Author: Sean Tichenor
# Purpose: Enable and validate ADB recognition for OliviaAI_RetainerMap
# ====================================================================

# Check ADB availability
if ! command -v adb &> /dev/null; then
  echo "[ERROR] ADB not found. Installing ADB..."
  pkg install android-tools -y
fi

echo "[ADB] Starting ADB server..."
adb start-server
sleep 1

echo "[ADB] Checking for connected devices..."
adb wait-for-device

# Detect device
DEVICE_ID=$(adb devices | grep -w "device" | awk '{print $1}')

if [ -z "$DEVICE_ID" ]; then
  echo "[ERROR] No authorized ADB device found."
  echo " > Make sure USB Debugging is enabled"
  echo " > Accept the prompt on your Android device"
  exit 1
fi

echo "[OK] ADB device recognized: $DEVICE_ID"

# Optional: Enable root ADB (for rooted phones)
echo "[ADB] Attempting root permissions..."
adb root || echo "[WARN] Root not available over ADB (non-rooted yet)"

# Optional: Confirm bootloader status
echo "[ADB] Verifying bootloader status..."
BOOTLOADER=$(adb shell getprop ro.boot.verifiedbootstate)
echo " > Verified Boot State: $BOOTLOADER"

# Device Info Dump (QQUAp signed if needed)
echo "[DEVICE INFO]"
adb shell getprop | grep "ro.product"

# Optional: Copy patched boot.img
if [ -f "./boot/patched_boot.img" ]; then
  echo "[ADB] Sending patched boot image to device..."
  adb push ./boot/patched_boot.img /sdcard/
  echo " > Transfer complete: /sdcard/patched_boot.img"
else
  echo "[WARN] No patched_boot.img found in ./boot/"
fi

# Mark trust state
echo "TRUSTED_ADB_DEVICE=$DEVICE_ID" > deploy/adb_trust.flag
echo "[✓] ADB trust session established and sealed under TGDK protocols."
