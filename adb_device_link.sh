#!/bin/bash
# ====================================================================
# TGDK ADB DEVICE LINK SCRIPT - EXTENDED
# LICENSE: D2501-V01 | Operator: Sean Tichenor
# ====================================================================

BOOT_IMAGE="./boot/patched_boot.img"
HASH_LOG="./deploy/patched_boot.qquap.hash"

# Step 0: Verify dependencies
command -v adb >/dev/null || pkg install android-tools -y
command -v fastboot >/dev/null || pkg install android-tools -y
command -v openssl >/dev/null || pkg install openssl-tool -y

# Step 1: Start ADB
echo "[ADB] Starting ADB service..."
adb start-server
sleep 1

echo "[ADB] Waiting for device authorization..."
adb wait-for-device

DEVICE_ID=$(adb devices | grep -w "device" | awk '{print $1}')

if [ -z "$DEVICE_ID" ]; then
  echo "[ERROR] No authorized device detected."
  exit 1
fi

echo "[✓] Device connected: $DEVICE_ID"

# Step 2: Dump device identity
echo "[INFO] Device fingerprint:"
adb shell getprop | grep "ro.product"

# Step 3: Check for patched boot image
if [ ! -f "$BOOT_IMAGE" ]; then
  echo "[ERROR] patched_boot.img not found at $BOOT_IMAGE"
  exit 1
fi

# Step 4: Generate QQUAp-style hash
echo "[QQUAp] Sealing boot image..."
openssl dgst -sha512 "$BOOT_IMAGE" > "$HASH_LOG"
echo "[HASH] Boot image sealed as:"
cat "$HASH_LOG"

# Step 5: Transfer to device
adb push "$BOOT_IMAGE" /sdcard/patched_boot.img
echo "[ADB] Patched boot image pushed to /sdcard/"

# Step 6: Reboot to fastboot
echo "[ADB] Rebooting to bootloader..."
adb reboot bootloader
sleep 5

# Step 7: Fastboot flash if unlocked
echo "[FASTBOOT] Flashing patched boot image..."
fastboot devices
fastboot flash boot "$BOOT_IMAGE" && echo "[✓] Boot flashed successfully."

# Optional unlock prompt
fastboot oem unlock || echo "[WARN] OEM unlock may be required manually."

# Step 8: Final seal
echo "TRUSTED_ADB_DEVICE=$DEVICE_ID" > deploy/adb_trust.flag
echo "BOOT_IMAGE_HASH=$(cat $HASH_LOG)" >> deploy/adb_trust.flag
echo "[✓] TGDK Flash sequence completed."
