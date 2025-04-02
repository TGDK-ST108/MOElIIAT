#!/bin/bash
# ====================================================================
# TGDK ZenUI Terminal Interface
# Author: Sean Tichenor
# Launches root/unlock tools from a simple terminal menu
# ====================================================================

while true; do
  clear
  echo "================================================="
  echo "             TGDK Zen Root & Unlock"
  echo "================================================="
  echo "1. OEM Unlock (Standard)"
  echo "2. OEM Unlock Vortex (USB Entropy Pulse)"
  echo "3. Root Device with Magisk (patch & flash)"
  echo "4. Odin Flash Instructions (manual)"
  echo "5. Exit"
  echo "================================================="
  read -p "Choose an option [1-5]: " choice

  case "$choice" in
    1) bash OEM_unlock.sh ;;
    2) bash oem_unlock_vortex.sh ;;
    3) bash magisk_flash.sh ;;
    4)
      clear
      echo "[ODIN MODE]"
      echo "1. Power off phone"
      echo "2. Hold [Vol Down + Bixby + Power] or [Vol Down + Vol Up + USB]"
      echo "3. Use Odin 3.14.4"
      echo "4. Load patched boot.img.tar into AP slot"
      echo "5. Uncheck Auto-Reboot, press Start"
      echo "6. Manually boot to Recovery to complete"
      read -p "Press Enter to return to menu..."
      ;;
    5) echo "Exiting ZenUI." ; exit 0 ;;
    *) echo "Invalid option. Try again." ; sleep 1 ;;
  esac
done