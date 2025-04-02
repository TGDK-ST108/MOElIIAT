#!/bin/bash
# TGDK UNIVERSAL OEM UNLOCK
# Compatible with most Android/Snapdragon/Samsung devices
# Author: Sean Tichenor

set -e
LOG="deploy/oem_unlock.log"
mkdir -p deploy

log() {
    echo "[OEM] $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [OEM] $1" >> "$LOG"
}

log "Starting OEM unlock sequence..."

# Check tools
for cmd in adb fastboot; do
    if ! command -v $cmd &>/dev/null; then
        log "$cmd not found. Install android-tools."
        exit 1
    fi
done

# Check device
log "Waiting for ADB device..."
adb wait-for-device

DEVICE_ID=$(adb devices | grep -w "device" | awk '{print $1}')
if [ -z "$DEVICE_ID" ]; then
    log "No ADB device detected."
    exit 2
fi
log "Device connected: $DEVICE_ID"

# Check device brand
BRAND=$(adb shell getprop ro.product.manufacturer | tr -d '\r')
MODEL=$(adb shell getprop ro.product.model | tr -d '\r')
log "Detected device: $BRAND $MODEL"

# Samsung-specific check
if [[ "$BRAND" == "samsung" ]]; then
    log "Samsung device detected."
    OEM_STATUS=$(adb shell getprop ro.boot.oem_unlock_supported)
    if [[ "$OEM_STATUS" == "0" ]]; then
        log "OEM Unlock not supported on this Samsung firmware."
        exit 33
    fi
fi

# Reboot to bootloader
log "Rebooting into bootloader (fastboot)..."
adb reboot bootloader
sleep 5

# Confirm fastboot presence
if ! fastboot devices | grep -q .; then
    log "Fastboot not available. Samsung devices may require ODIN/Download Mode."
    exit 3
fi

# OEM unlock command
log "Issuing 'fastboot oem unlock'..."
fastboot oem unlock || {
    log "Unlock failed. OEM unlock may be disabled in firmware."
    exit 4
}

# Optional reboot
read -p "[OEM] Reboot to system now? (y/n): " choice
[[ "$choice" == "y" ]] && fastboot reboot

log "OEM unlock complete."