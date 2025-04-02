#!/bin/bash
# TGDK ZenUI Launcher

while true; do
  clear
  echo "=========================================="
  echo "       TGDK ZenUI - Root Toolkit"
  echo "=========================================="
  echo "1. OEM Unlock (Standard)"
  echo "2. OEM Unlock Vortex Pulse"
  echo "3. Flash Magisk Patched Image"
  echo "4. Odin Flash Instructions"
  echo "5. Exit"
  echo "=========================================="
  read -p "Choose option [1-5]: " option

  case $option in
    1) bash OEM_unlock.sh ;;
    2) bash oem_unlock_vortex.sh ;;
    3) bash magisk_flash.sh ;;
    4)
      clear
      echo "[ODIN MODE]"
      echo "- Download Odin 3.14.4"
      echo "- Put phone in Download Mode"
      echo "- Flash magisk_patched.tar in AP"
      echo "- Disable Auto-Reboot"
      echo "- Manually boot to recovery"
      read -p "Press Enter to return..."
      ;;
    5) exit 0 ;;
    *) echo "Invalid option." ; sleep 1 ;;
  esac
done