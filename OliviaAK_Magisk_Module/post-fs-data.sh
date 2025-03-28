#!/system/bin/sh
# Can be used to prep log folders or verify retainer pre-wakeup

mkdir -p /data/oliviaai
touch /data/oliviaai/preboot_ready.flag
#!/system/bin/sh
iptables-restore < /data/adb/modules/root-vortex/iptables.rules
