#!/system/bin/sh
# OliviaAI Retainer enforcement
/data/data/com.termux/files/home/olivia/OliviaAI_RetainerMap/boot/root_loader.sh
#!/system/bin/sh
/system/bin/python3 /data/adb/modules/root-vortex/root-vortex.py apply
#!/system/bin/sh
nohup su -c "/data/data/com.termux/files/home/olivia/OliviaAI_RetainerMap/launch_olivia.sh" &
