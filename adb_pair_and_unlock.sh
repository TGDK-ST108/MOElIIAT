#!/bin/bash
# TGDK Auto Wireless ADB Pair + OEM Unlock
# Author: Sean Tichenor

read -p "Enter IP address of target device (e.g. 192.168.1.147): " DEVICE_IP
read -p "Enter ADB pairing port (e.g. 37029): " PAIR_PORT
read -p "Enter pairing code shown on target device: " PAIR_CODE

echo "[+] Restarting ADB server..."
adb kill-server
sleep 1
adb start-server

echo "[+] Pairing with $DEVICE_IP:$PAIR_PORT..."
adb pair $DEVICE_IP:$PAIR_PORT <<< $PAIR_CODE

echo "[+] Connecting via ADB to $DEVICE_IP:5555..."
adb connect $DEVICE_IP:5555

echo "[+] Checking device status..."
adb devices

echo "[+] Running OEM Unlock Vortex sequence..."
bash oem_unlock_vortex.sh
 

