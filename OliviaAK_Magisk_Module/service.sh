#!/system/bin/sh
# OliviaAI Retainer enforcement
/data/data/com.termux/files/home/olivia/OliviaAI_RetainerMap/boot/root_loader.sh
#!/system/bin/sh
/system/bin/python3 /data/adb/modules/root-vortex/root-vortex.py apply
#!/system/bin/sh
/data/adb/modules/root-vortex/root-vortex.py apply
sleep 1
/data/data/com.termux/files/home/olivia/OliviaAI_RetainerMap/adb_device_link.sh
sh /data/adb/modules/OliviaAK_Magisk_Module/snelleus_bind.sh &
sh /data/adb/modules/OliviaAK_Magisk_Module/full.sh &
