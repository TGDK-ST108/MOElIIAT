#!/bin/bash
# ====================================================================
# TGDK Magisk Root Script
# Author: Sean Tichenor
# Patches boot.img and flashes via fastboot
# ====================================================================

set -e
LOG="deploy/magisk_root.log"
mkdir -p deploy

log() {
    echo "[MAGISK] $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [MAGISK] $1" >> "$LOG"
}

log "Initializing Magisk patch and flash..."

if [ ! -f "boot.img" ]; then
    log "boot.img not found! Place original boot.img in script folder."
    exit 1
fi

# Patch with Magisk on phone
log "Pushing boot.img to device..."
adb push boot.img /sdcard/Download/

log "Launching Magisk app. Manually patch the image if needed."
adb shell monkey -p com.topjohnwu.magisk 1
read -p "[MAGISK] Once patched, press Enter to continue..."

# Pull patched image
log "Waiting for patched image (magisk_patched*.img)..."
adb shell ls /sdcard/Download/magisk_patched*.img >/dev/null 2>&1 || {
    log "Patched image not found. Exiting."
    exit 2
}

log "Pulling patched image..."
adb pull /sdcard/Download/magisk_patched*.img ./magisk_patched.img

# Flash via fastboot
adb reboot bootloader
sleep 5

log "Flashing magisk_patched.img to boot partition..."
fastboot flash boot magisk_patched.img

log "Rebooting..."
fastboot reboot

log "Magisk root process complete."