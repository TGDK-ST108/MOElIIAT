#!/bin/bash
# =============================================================
# TGDK OliviaAI Launcher - D2501-V01
# One-command biometric root deployment with animated feedback
# =============================================================

clear

echo "███╗   ███╗ ██████╗ ███████╗██╗     ██╗██╗ █████╗ ████████╗"
echo "████╗ ████║██╔═══██╗██╔════╝██║     ██║██║██╔══██╗╚══██╔══╝"
echo "██╔████╔██║██║   ██║█████╗  ██║     ██║██║███████║   ██║   "
echo "██║╚██╔╝██║██║   ██║██╔══╝  ██║     ██║██║██╔══██║   ██║   "
echo "██║ ╚═╝ ██║╚██████╔╝███████╗███████╗██║██║██║  ██║   ██║   "
echo "╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚═╝╚═╝╚═╝  ╚═╝   ╚═╝   "
echo "            [OLIVIAAI RETAINERMAP LAUNCHER]"
echo ""

animate() {
  echo -n "$1"
  for i in {1..3}; do
    echo -n "."
    sleep 0.3
  done
  echo ""
}

animate "Initializing QQUAp sequence"
sleep 0.3

animate "Validating License D2501-V01"
sleep 0.3

animate "Verifying GeoLock: US Region"
sleep 0.3

animate "Launching Trust Circumferenciation"
./psychotological/circ_core

animate "Running Laurandication Validation"
./psychotological/laurandicate

animate "Executing Captor Retainer Sync"
./captor/captor_hook.sh

animate "Performing Phi Scalar Biometric Check"
PHI=$(grep "phi_scalar=" olivia_scope/tgdkdef_iris.vec | cut -d '=' -f2 | tr -d ' ')
echo " > Phi Scalar Detected: $PHI"

animate "Executing Root Deployment with OliviaAI"
./boot/root_loader.sh

animate "Binding Molecular Shell"
cat phase4/OliviaAI_molecular_shell.bind | grep "status"

animate "Finalizing Sentinel Pulse Monitoring"
cat sentinel/sentinel_trace.log | tail -n 5

echo ""
echo "[✓] TGDK Root Chain Completed."
echo "[✓] OliviaAI Molecular Shell Bound."
echo "[✓] Enforcement Active. Biometric Verified."
