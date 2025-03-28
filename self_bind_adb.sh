#!/system/bin/sh
# TGDK Snelleus Self-Recognition Bridge
# Maintains internal ADB binding and connection loop
echo "[SELF-BIND] Initiating Snelleus USB stack recognition..."
mkdir -p "$HOME/.tgdk"
LOGFILE="$HOME/.tgdk/snelleus_bind.log"
ADB_PORT="5555"
RETRY_DELAY=5

mkdir -p "$(dirname "$LOGFILE")"

log() {
  echo "[SNELLEUS] $1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') [SNELLEUS] $1" >> "$LOGFILE"
}

log "Daemon started. Monitoring ADB on TCP:$ADB_PORT"

while :; do
  USB_STATE=$(getprop sys.usb.state 2>/dev/null || echo "unavailable")
  ADB_PORT_STATE=$(getprop service.adb.tcp.port 2>/dev/null || echo "unavailable")

  if echo "$USB_STATE" | grep -q "adb"; then
    log "ADB active. Port: $ADB_PORT_STATE | State: $USB_STATE"
  else
    log "ADB dropped or state unavailable. (Rebinding skipped: not permitted)"
  fi

  sleep $RETRY_DELAY
done
# Phase 1: Initial Rebind Attempt
setprop service.adb.tcp.port 5555
setprop sys.usb.config none
stop adbd
sleep 1
setprop sys.usb.config adb
setprop sys.usb.state adb
start adbd
sleep 2

# Phase 2: Loop to Maintain Connection
MAX_RETRIES=30
RETRY_DELAY=2

echo "[SELF-BIND] Verifying ADB TCP state loop..."

i=0
while [ $i -lt $MAX_RETRIES ]; do
    TCP_PORT=$(getprop service.adb.tcp.port)
    USB_STATE=$(getprop sys.usb.state)

    echo "[SELF-BIND] Loop $((i+1)) — Port:$TCP_PORT  State:$USB_STATE"

    if echo "$USB_STATE" | grep -q "adb"; then
        echo "[SELF-BIND] ADB state active. Confirmed."
        break
    else
        echo "[SELF-BIND] ADB state dropped. Rebinding..."
        setprop sys.usb.config none
        stop adbd
        sleep 1
        setprop sys.usb.config adb
        setprop sys.usb.state adb
        start adbd
    fi

    i=$((i+1))
    sleep $RETRY_DELAY
done

# Final Check
echo "[SELF-BIND] Final ADB Registration:"
adb devices
ps | grep adbd

# =====================================================
# TGDK Snelleus ADB Self-Bind Daemon
# Maintains persistent ADB TCP loopback via Snelleus
# License: D2501-V01 | Operator: Sean Tichenor
# =====================================================

LOGFILE="/data/selfroot/snelleus_bind.log"
ADB_PORT="5555"
MAX_RETRIES=0  # 0 = infinite
RETRY_DELAY=5  # seconds between checks

log() {
  echo "[SNELLEUS] $1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') [SNELLEUS] $1" >> "$LOGFILE"
}

log "Daemon started. Binding ADB over TCP:$ADB_PORT"

# Set TCP port only once
setprop service.adb.tcp.port $ADB_PORT

while :; do
  USB_STATE=$(getprop sys.usb.state)
  ADB_PORT_STATE=$(getprop service.adb.tcp.port)

  if echo "$USB_STATE" | grep -q "adb"; then
    log "ADB is active. Port: $ADB_PORT_STATE | State: $USB_STATE"
  else
    log "ADB dropped. Rebinding USB config..."
    setprop sys.usb.config none
    stop adbd
    sleep 1
    setprop sys.usb.config adb
    setprop sys.usb.state adb
    start adbd
    sleep 2
    log "Rebind attempted. Verifying next loop..."
  fi

  sleep $RETRY_DELAY
done


./full.sh \
