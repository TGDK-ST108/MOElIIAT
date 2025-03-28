#!/bin/bash
# ====================================================================
# TGDK OEM Unlock Vortex
# License: D2501-V01 | Operator: Sean Tichenor
# Rebinds USB, forces device detection, and triggers OEM unlock
# ====================================================================

set -e
LOG="deploy/oem_unlock_vortex.log"
mkdir -p deploy

log() {
    echo "[OEM-VORTEX] $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [OEM-VORTEX] $1" >> "$LOG"
}

log "Initializing OEM Unlock Vortex..."

# Step 1: Kill and restart ADB
adb kill-server
sleep 1
adb start-server
log "ADB server restarted."

# Step 2: Snelled USB entropy ping (Vortex pulse)
log "Pulsing USB snelled entropy recognition..."
for i in {1..5}; do
    echo -n "QQUAp-PING-$RANDOM$RANDOM " >> /dev/null
    sleep 0.4
done

# Step 3: Wait loop for ADB device
log "Waiting for device to respond over USB..."
for i in {1..10}; do
    DEVICE=$(adb devices | grep -w "device" | awk '{print $1}')
    if [ ! -z "$DEVICE" ]; then
        log "Device recognized: $DEVICE"
        break
    fi
    echo "[WAIT] No response yet ($i)..."
    sleep 1
done

if [ -z "$DEVICE" ]; then
    log "ERROR: No ADB device detected after snelled pulse."
    exit 144
fi

# Step 4: Reboot into bootloader
log "Rebooting to bootloader..."
adb reboot bootloader
sleep 5

# Step 5: Reconfirm in fastboot
log "Checking fastboot devices..."
FASTBOOT_DEVICE=$(fastboot devices | awk '{print $1}')
if [ -z "$FASTBOOT_DEVICE" ]; then
    log "ERROR: Device not seen in fastboot. Check USB and try again."
    exit 1
fi
log "Fastboot device confirmed: $FASTBOOT_DEVICE"

# Step 6: OEM Unlock
log "Issuing fastboot oem unlock..."
fastboot oem unlock || {
    log "ERROR: OEM unlock failed. Bootloader may be protected."
    exit 1
}

# Optional: Reboot
read -p "[OEM-VORTEX] Reboot to system now? (y/n): " choice
if [[ "$choice" == "y" ]]; then
    fastboot reboot
    log "Device rebooted."
else
    log "Device remains in bootloader."
fi

log "OEM Unlock Vortex completed."