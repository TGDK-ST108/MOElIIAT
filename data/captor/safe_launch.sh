#!/bin/bash

if [ -f /.proot ]; then
  echo "[ERROR] You're in PRoot (e.g., Fedora). ADB and root cannot function here."
  echo "Please run this from native Termux."
  exit 144
else
  ./adb_device_link.sh
fi
