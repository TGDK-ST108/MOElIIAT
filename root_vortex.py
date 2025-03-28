#!/system/bin/python3
import os
import subprocess
import sys
import time

ROOT_VORTEX_PATH = "/data/adb/modules/root-vortex/"
IPTABLES_RULES_FILE = f"{ROOT_VORTEX_PATH}iptables.rules"
LOG_FILE = f"{ROOT_VORTEX_PATH}root-vortex.log"

# Logging function
def log(message):
    with open(LOG_FILE, "a") as log_file:
        log_file.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - {message}\n")
    print(f"[Root-Vortex] {message}")

# Check if running as root
def check_root():
    return os.geteuid() == 0

# Apply iptables rules
def apply_iptables():
    log("Applying iptables rules...")
    
    commands = [
        "iptables -F",  # Flush all rules
        "iptables -X",  # Delete all chains
        "iptables -P INPUT DROP",  # Drop all incoming traffic
        "iptables -P FORWARD DROP",
        "iptables -P OUTPUT ACCEPT",  # Allow all outgoing traffic
        "iptables -A INPUT -i lo -j ACCEPT",  # Allow loopback
        "iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT",  # Allow existing connections
        "iptables -A INPUT -p tcp --dport 22 -j ACCEPT",  # Allow SSH (modify as needed)
        f"iptables-save > {IPTABLES_RULES_FILE}"  # Save rules
    ]

    for cmd in commands:
        subprocess.run(cmd, shell=True)
    
    log("iptables rules applied successfully.")

# Restore iptables rules
def restore_iptables():
    if os.path.exists(IPTABLES_RULES_FILE):
        subprocess.run(f"iptables-restore < {IPTABLES_RULES_FILE}", shell=True)
        log("iptables rules restored.")
    else:
        log("No saved iptables rules found.")

# Ensure persistence via Magisk
def setup_persistence():
    log("Setting up persistence...")
    
    post_fs_data_script = f"""/system/bin/sh
    iptables-restore < {IPTABLES_RULES_FILE}
    """
    
    service_script = f"""/system/bin/sh
    nohup /system/bin/python3 {ROOT_VORTEX_PATH}root-vortex.py &>/dev/null &
    """

    with open(f"{ROOT_VORTEX_PATH}post-fs-data.sh", "w") as f:
        f.write(post_fs_data_script)
    with open(f"{ROOT_VORTEX_PATH}service.sh", "w") as f:
        f.write(service_script)

    os.chmod(f"{ROOT_VORTEX_PATH}post-fs-data.sh", 0o755)
    os.chmod(f"{ROOT_VORTEX_PATH}service.sh", 0o755)

    log("Persistence setup completed.")

# Display status
def show_status():
    print("\n[Root-Vortex Status]")
    subprocess.run("iptables -L -v -n", shell=True)
    print("\n[Root-Vortex Logs]")
    subprocess.run(f"tail -n 10 {LOG_FILE}", shell=True)

# Main function
def main():
    if not check_root():
        log("Error: Script must be run as root.")
        sys.exit(1)

    if len(sys.argv) < 2:
        log("Usage: root-vortex.py <apply|restore|status>")
        sys.exit(1)

    action = sys.argv[1].lower()
    
    if action == "apply":
        apply_iptables()
        setup_persistence()
    elif action == "restore":
        restore_iptables()
    elif action == "status":
        show_status()
    else:
        log("Invalid command. Use: apply | restore | status")

if __name__ == "__main__":
    main()
