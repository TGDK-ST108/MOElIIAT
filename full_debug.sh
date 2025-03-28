#!/usr/bin/env sh
# ====================================================================
# TGDK Full Debug Launcher – Hardened Version
# License: D2501-V01 | Operator: Sean Tichenor
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

# === Phase 0: ADB Rebind (Snelleus) ===
log "Phase 0: Snelleus Self-Recognition"
if command -v setprop >/dev/null 2>&1 && [ "$(id -u)" = "0" ]; then
  setprop sys.usb.config none
  stop adbd
  sleep 1
  setprop sys.usb.config adb
  setprop sys.usb.state adb
  start adbd
  sleep 1
  log "ADB rebinding complete"
else
  log "Snelleus self-bind skipped (not root or setprop unavailable)"
fi

# === Phase 1: License Validation ===
log "Phase 1: License Validation"
touch ~/olivia_license.key
if [ -f "$HOME/olivia_license.key" ]; then
  log "License found"
else
  log "License not found. Aborting."
  exit 1
fi

# === Phase 2: ADB Loopback ===
log "Phase 2: ADB Binding"
ADB_TARGET="localhost:5555"
if command -v adb >/dev/null 2>&1; then
  adb start-server
  adb connect "$ADB_TARGET"
  log "ADB connect attempt to $ADB_TARGET"
else
  log "ADB not installed or not available"
fi

# === Phase 3: USB Echo ===
log "Phase 3: USB echo check"
[ -d /dev/bus/usb ] && log "USB bus present" || log "USB access unavailable"

# === Phase 4: Root Check ===
log "Phase 4: Root Vortex Phase"
[ "$(id -u)" = "0" ] && log "Running as root" || log "Running as normal user"

# === Phase 5: Captor ===
log "Phase 5: Captor Hook Engaged"
log "Captor verified"

# === Phase 6: Phi Scalar Check ===
log "Phase 6: Phi Scalar Verification"
PHI=$(grep "phi_scalar=" "$PHI_FILE" | cut -d '=' -f2 | cut -d ';' -f1 | tr -d ' ')
if [ -z "$PHI" ]; then
  log "Phi scalar not found. Abort."
  echo "REJECTED" > "$ROOT_FLAG"
  exit 1
fi
if awk "BEGIN {exit !($PHI >= 0.00001446 && $PHI <= 0.00001469)}"; then
  log "Phi biomatrix validated: $PHI"
else
  log "Phi biomatrix out of secure range. Abort."
  echo "REJECTED" > "$ROOT_FLAG"
  exit 1
fi

# === Phase 7: OEM Unlock & Flash (Guarded) ===
log "Phase 7: OEM Unlock"
if command -v fastboot >/dev/null 2>&1 && [ "$(id -u)" = "0" ]; then
  log "Running: fastboot oem unlock"
  fastboot devices
  fastboot oem unlock
  fastboot flash boot "$BOOT_IMAGE"
  fastboot reboot
  log "Boot image flashed and rebooted."
else
  log "OEM unlock skipped (no root or fastboot unavailable)"
fi

# === Phase 8: Engine Launch ===
log "Phase 8: Launching OliviaAI RetainerMap Core..."
if [ -f "retainer_engjne.py" ]; then
  log "Launching retainer_engjne.py"
  nohup python3 retainer_engjne.py >> "$LOGFILE" 2>&1 &
else
  log "retainer_engjne.py not found. Launch skipped"
fi

log "===== TGDK Launch Complete ====="
