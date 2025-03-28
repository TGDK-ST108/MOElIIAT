#!/bin/bash
# ====================================================================
# TGDK Snelleus USB Echo Trigger
# License: D2501-V01 | Operator: Sean Tichenor
# Purpose: Trick Android device into re-identifying over USB
# ====================================================================

LOG="deploy/snelleus_usb_echo.log"
mkdir -p deploy

log() {
  echo "[SNELLEUS] $1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') [SNELLEUS] $1" >> "$LOG"
}

log "Initializing Snelleus USB Echo Pulse..."

# Step 1: Kill and restart ADB
adb kill-server
sleep 1
adb start-server
log "ADB restarted."

# Step 2: Simulate loopback USB entropy
log "Sending QQUAp entropy pulse..."
for i in {1..10}; do
  echo -n "QQUAp-USB-$RANDOM$RANDOM" > /dev/null
  sleep 0.2
done

# Step 3: Try binding common USB controller device paths (Android side)
log "Triggering common USB controller paths (echo pulse)..."
USB_PATHS=(
  "/sys/bus/usb/drivers/usb/unbind"
  "/sys/bus/usb/drivers/usb/bind"
)

for path in "${USB_PATHS[@]}"; do
  if [ -e "$path" ]; then
    echo "1-1" > "$path" 2>/dev/null
    sleep 0.2
    echo "1-1" > "$path" 2>/dev/null
    log "USB path pulsed: $path"
  fi
done

# Step 4: Pulse adb and logcat
log "Forcing ADB detection..."
for i in {1..5}; do
  adb devices
  adb shell getprop sys.usb.state 2>/dev/null | tee -a "$LOG"
  sleep 1
done

# Step 5: Evaluate result
DEVICE=$(adb devices | grep -w "device" | awk '{print $1}')
if [ -z "$DEVICE" ]; then
  log "ERROR: No ADB device detected after Snelleus pulse."
  echo "[FAIL] Snelleus echo unsuccessful. Try rebooting device or checking cable."
  exit 144
fi

log "Success: Device identified as $DEVICE"
echo "[✓] Device re-announced itself successfully!"