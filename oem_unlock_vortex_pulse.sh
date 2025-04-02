#!/bin/bash
# TGDK OEM UNLOCK VORTEX
# Author: Sean Tichenor

set -e
LOG="deploy/oem_unlock_vortex.log"
mkdir -p deploy

log() {
    echo "[OEM-VORTEX] $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [OEM-VORTEX] $1" >> "$LOG"
}

log "Initializing OEM Unlock Vortex..."

adb kill-server && sleep 1 && adb start-server
log "ADB server restarted."

for i in {1..5}; do
    echo -n "QQUAp-PULSE-$RANDOM$RANDOM " >> /dev/null
    sleep 0.4
done

log "Waiting for USB handshake..."
for i in {1..10}; do
    DEVICE=$(adb devices | grep -w "device" | awk '{print $1}')
    [[ ! -z "$DEVICE" ]] && break
    echo "[WAIT] Ping $i/10..."
    sleep 1
done

if [[ -z "$DEVICE" ]]; then
    log "No ADB device detected after vortex pulse."
    exit 144
fi

log "Device detected: $DEVICE"

adb reboot bootloader
sleep 5

FASTBOOT_DEVICE=$(fastboot devices | awk '{print $1}')
if [[ -z "$FASTBOOT_DEVICE" ]]; then
    log "Fastboot not detected. Samsung may require Odin."
    exit 5
fi
log "Fastboot device: $FASTBOOT_DEVICE"

log "Sending OEM unlock..."
fastboot oem unlock || {
    log "Unlock failed or not supported."
    exit 6
}

read -p "[OEM-VORTEX] Reboot to system? (y/n): " choice
[[ "$choice" == "y" ]] && fastboot reboot

log "OEM Unlock Vortex complete."