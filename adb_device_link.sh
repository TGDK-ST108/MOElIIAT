#!/bin/bash
# ====================================================================
# TGDK ADB DEVICE LINK + AUTO FLASH + BOOT + ROOT LAUNCHER
# LICENSE: D2501-V01 | OPERATOR: SEAN TICHENOR
# ====================================================================

BOOT_IMAGE="./boot/patched_boot.img"
HASH_LOG="./deploy/patched_boot.qquap.hash"
TRUST_FLAG="./deploy/adb_trust.flag"
LAUNCH_SCRIPT="./launch_olivia.sh"

# Dependency check
for bin in adb fastboot openssl; do
  if ! command -v $bin &>/dev/null; then
    echo "[INSTALL] Missing $bin. Installing..."
    pkg install -y android-tools openssl-tool
  fi
done

# Start ADB
echo "[ADB] Starting ADB service..."
adb start-server
sleep 1
adb wait-for-device

DEVICE_ID=$(adb devices | grep -w "device" | awk '{print $1}')
if [ -z "$DEVICE_ID" ]; then
  echo "[ERROR] No device authorized. Please approve USB Debugging."
  exit 1
fi

echo "[✓] ADB device recognized: $DEVICE_ID"
adb shell getprop | grep "ro.product"

# Verify boot image
if [ ! -f "$BOOT_IMAGE" ]; then
  echo "[ERROR] patched_boot.img not found at $BOOT_IMAGE"
  exit 1
fi

# QQUAp hash seal
echo "[QQUAp] Hashing patched_boot.img..."
openssl dgst -sha512 "$BOOT_IMAGE" > "$HASH_LOG"
echo "[HASH] Sealed SHA-512:"
cat "$HASH_LOG"

# Push image and reboot
adb push "$BOOT_IMAGE" /sdcard/patched_boot.img
echo "[ADB] Rebooting to fastboot..."
adb reboot bootloader
sleep 5

# Flash and unlock
echo "[FASTBOOT] Flashing image..."
fastboot devices
fastboot flash boot "$BOOT_IMAGE"
fastboot oem unlock || echo "[NOTICE] OEM unlock prompt may appear."

# Reboot to Android
fastboot reboot
echo "[FASTBOOT] Rebooting to system..."
sleep 15

# Wait for ADB reconnect
echo "[ADB] Waiting for device to come back online..."
adb wait-for-device
sleep 5

# Validate Magisk installation
echo "[MAGISK] Checking Magisk root status..."
MAGISK_STATE=$(adb shell su -c 'magisk -v' 2>/dev/null)
if [ -z "$MAGISK_STATE" ]; then
  echo "[WARN] Magisk not detected via ADB SU. Root may not be active yet."
else
  echo "[MAGISK] Magisk Version Detected: $MAGISK_STATE"
fi

# Record trust
echo "TRUSTED_ADB_DEVICE=$DEVICE_ID" > "$TRUST_FLAG"
echo "BOOT_IMAGE_HASH=$(cat $HASH_LOG)" >> "$TRUST_FLAG"

# Launch OliviaAI sequence
echo "[TGDK] Launching OliviaAI biometric root sequence..."
if [ -f "$LAUNCH_SCRIPT" ]; then
  chmod +x "$LAUNCH_SCRIPT"
  bash "$LAUNCH_SCRIPT"
else
  echo "[ERROR] launch_olivia.sh not found!"
fi
