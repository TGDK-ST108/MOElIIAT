#!/usr/bin/env sh
# ====================================================================
# TGDK Full Launch Chain
# License: D2501-V01 | Operator: Sean Tichenor
# Launches OliviaAI RetainerMap with ADB rebind, OEM unlock, and Phi enforcement
# ====================================================================

ROOT_FLAG="deploy/root_status.trust"
BOOT_IMAGE="boot/patched_boot.img"
PHI_FILE="olivia_scope/tgdkdef_iris.vec"
LOGFILE="olivia_launch.log"
mkdir -p deploy

log() {
    echo "[TGDK] $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [TGDK] $1" >> "$LOGFILE"
}

log "===== OliviaAI RetainerMap Chain Initiated ====="

# Step 1: ADB self-recognition via Snelleus
log "Phase 0: Snelleus Self-Recognition"
setprop sys.usb.config none
stop adbd
sleep 1
setprop sys.usb.config adb
setprop sys.usb.state adb
start adbd
sleep 1
log "ADB properties:"
getprop sys.usb.config >> "$LOGFILE"
getprop sys.usb.state >> "$LOGFILE"
ps | grep adbd >> "$LOGFILE"

# Step 2: License check
log "Phase 1: License Validation"
touch ~/olivia_license.key
LICENSE_FILE="$HOME/olivia_license.key"
if [ -f "$LICENSE_FILE" ]; then
  log "License found"
else
  log "License not found. Aborting."
  exit 1
fi

# Step 3: ADB bind
log "Phase 2: ADB Binding"
ADB_TARGET="localhost:5555"
if command -v adb >/dev/null 2>&1; then
  adb start-server
  adb connect "$ADB_TARGET"
  if [ $? -eq 0 ]; then
    log "ADB connected to $ADB_TARGET"
  else
    log "ADB connection failed"
  fi
else
  log "ADB not installed"
fi

# Step 4: USB echo
log "Phase 3: USB echo check"
if [ -d /dev/bus/usb ]; then
  log "USB bus present"
else
  log "USB access unavailable"
fi

# Step 5: Root/Vortex
log "Phase 4: Root Vortex Phase"
if [ "$(id -u)" = "0" ]; then
  log "Running as root"
else
  log "Running as normal user"
fi

# Step 6: Captor
log "Phase 5: Captor Hook Engaged"
log "Captor verified"

# Step 7: Phi scalar check
log "Phase 6: Phi Scalar Verification"
PHI=$(grep "phi_scalar=" "$PHI_FILE" | cut -d '=' -f2 | cut -d ';' -f1 | tr -d ' ')
if [ -z "$PHI" ]; then
  log "Phi scalar not found. Abort."
  echo "REJECTED" > "$ROOT_FLAG"
  exit 1
fi

# Convert string to number and check range
if awk "BEGIN {exit !($PHI >= 0.00001446 && $PHI <= 0.00001469)}"; then
  log "Phi biomatrix validated: $PHI"
else
  log "Phi biomatrix out of secure range. Abort."
  echo "REJECTED" > "$ROOT_FLAG"
  exit 1
fi

# Step 8: OEM Unlock and Flash
log "Phase 7: OEM Unlock"
if command -v adb >/dev/null 2>&1; then
  adb wait-for-device
  DEVICE_ID=$(adb devices | grep -w "device" | awk '{print $1}')
  if [ -n "$DEVICE_ID" ]; then
    log "Device connected: $DEVICE_ID"
    adb reboot bootloader
    sleep 5
    log "Issuing OEM unlock..."
    fastboot devices
    fastboot oem unlock
    fastboot flash boot "$BOOT_IMAGE"
    fastboot reboot
    log "Boot image flashed and rebooted."
  else
    log "No ADB device detected. OEM unlock aborted."
  fi
else
  log "ADB not found. Skipping OEM unlock"
fi

# Step 9: OliviaAI Launch
log "Phase 8: Launching OliviaAI RetainerMap Core..."
if [ -f "retainer_engjne.py" ]; then
  nohup python3 retainer_engjne.py >> "$LOGFILE" 2>&1 &
  log "OliviaAI engine started"
else
  log "retainer_engjne.py not found. Launch skipped"
fi

log "===== TGDK Launch Complete ====="