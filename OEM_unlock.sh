#!/bin/bash
# ====================================================================
# TGDK OEM UNLOCK SCRIPT
# License: D2501-V01 | Operator: Sean Tichenor
# Unlocks Android bootloader with confirmation via USB debugging
# ====================================================================

set -e
LOG="deploy/oem_unlock.log"
mkdir -p deploy

log() {
    echo "[OEM] $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [OEM] $1" >> "$LOG"
}

log "Starting OEM unlock sequence..."

# Step 1: Check ADB
if ! command -v adb &> /dev/null; then
    log "ADB not found. Install android-tools."
    exit 1
fi

# Step 2: Detect device
log "Waiting for ADB device..."
adb wait-for-device

DEVICE_ID=$(adb devices | grep -w "device" | awk '{print $1}')
if [ -z "$DEVICE_ID" ]; then
    log "No ADB device detected."
    exit 1
fi
log "Device connected: $DEVICE_ID"

# Step 3: Reboot into bootloader
log "Rebooting into bootloader..."
adb reboot bootloader
sleep 5

# Step 4: Fastboot unlock
log "Issuing fastboot oem unlock (you must approve on-screen)..."
fastboot devices
fastboot oem unlock || {
    log "Fastboot unlock failed. Device may not support unlocking or was already unlocked."
    exit 1
}

log "OEM unlock command issued. Confirm on the device screen to continue."

# Optional: Reboot to system
read -p "[OEM] Reboot to system now? (y/n): " choice
if [[ "$choice" == "y" ]]; then
    fastboot reboot
    log "Device rebooted."
else
    log "Device remains in fastboot mode."
fi

log "OEM unlock sequence complete."