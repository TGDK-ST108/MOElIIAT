#!/bin/bash
# TGDK UNIVERSAL OEM UNLOCK
# Author: Sean Tichenor

set -e
LOG="deploy/oem_unlock.log"
mkdir -p deploy

log() {
    echo "[OEM] $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [OEM] $1" >> "$LOG"
}

log "Starting OEM unlock sequence..."

for cmd in adb fastboot; do
    if ! command -v $cmd &>/dev/null; then
        log "$cmd not found. Install android-tools."
        exit 1
    fi
done

log "Waiting for ADB device..."
adb wait-for-device

DEVICE_ID=$(adb devices | grep -w "device" | awk '{print $1}')
if [ -z "$DEVICE_ID" ]; then
    log "No ADB device detected."
    exit 2
fi
log "Device connected: $DEVICE_ID"

BRAND=$(adb shell getprop ro.product.manufacturer | tr -d '\r')
MODEL=$(adb shell getprop ro.product.model | tr -d '\r')
log "Detected device: $BRAND $MODEL"

if [[ "$BRAND" == "samsung" ]]; then
    log "Samsung device detected."
    OEM_STATUS=$(adb shell getprop ro.boot.oem_unlock_supported)
    if [[ "$OEM_STATUS" == "0" ]]; then
        log "OEM Unlock not supported on this Samsung firmware."
        exit 33
    fi
fi

adb reboot bootloader
sleep 5

if ! fastboot devices | grep -q .; then
    log "Fastboot not available. Samsung devices may require Odin."
    exit 3
fi

log "Issuing 'fastboot oem unlock'..."
fastboot oem unlock || {
    log "Unlock failed. OEM unlock may be disabled in firmware."
    exit 4
}

read -p "[OEM] Reboot to system now? (y/n): " choice
[[ "$choice" == "y" ]] && fastboot reboot

log "OEM unlock complete."