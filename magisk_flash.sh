#!/bin/bash
# TGDK Magisk Root Script

set -e
LOG="deploy/magisk_root.log"
mkdir -p deploy

log() {
    echo "[MAGISK] $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [MAGISK] $1" >> "$LOG"
}

log "Initializing Magisk flash..."

if [ ! -f "boot.img" ]; then
    log "boot.img not found."
    exit 1
fi

log "Pushing to device..."
adb push boot.img /sdcard/Download/

log "Launch Magisk app and patch manually now..."
adb shell monkey -p com.topjohnwu.magisk 1
read -p "[MAGISK] Once patched, press Enter to continue..."

adb pull /sdcard/Download/magisk_patched*.img ./magisk_patched.img

adb reboot bootloader
sleep 5

log "Flashing patched image..."
fastboot flash boot magisk_patched.img

fastboot reboot
log "Magisk flash complete."