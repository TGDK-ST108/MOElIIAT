import os
import hashlib
import time
import shutil
import subprocess
from datetime import datetime

BOOTLOADER_SCOPE = "/data/local/tmp/tgdkrogueboot"
LOG_FILE = f"{BOOTLOADER_SCOPE}/roguelog.txt"
TARGET_FILE = "/storage/emulated/0/Download/S721USQS3AYA1_S721UOYN3AYA1_TMB/AP_S721USQS3AYA1_S721USQS3AYA1_MQB92084295_REV00_user_low_ship_MULTI_CERT_meta_OS14.tar.md5"
SAFE_ROOT = "/system/TGDKSafeTGDKSafeRoot"
REMAKE_DIR = f"{BOOTLOADER_SCOPE}/remakes"

def init_environment():
    os.makedirs(BOOTLOADER_SCOPE, exist_ok=True)
    os.makedirs(REMAKE_DIR, exist_ok=True)
    with open(LOG_FILE, "a") as log:
        log.write(f"\n[BOOT] Initialized at {datetime.now()}\n")

def log(msg):
    with open(LOG_FILE, "a") as log:
        log.write(f"[{datetime.now()}] {msg}\n")

def hash_file(path):
    h = hashlib.md5()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b""):
            h.update(chunk)
    return h.hexdigest()

def excessive_remake():
    original_hash = hash_file(TARGET_FILE)
    for i in range(100):  # excessive remaking
        new_path = f"{REMAKE_DIR}/remake_{i}_{original_hash}.tar.md5"
        shutil.copy2(TARGET_FILE, new_path)
        log(f"Remade copy {i}: {new_path}")
        time.sleep(0.05)

def install_hooks():
    if os.path.exists(SAFE_ROOT):
        log("Using TGDKSafeTGDKSafeRoot for hook installation.")
        makeshift_hook = os.path.join(SAFE_ROOT, "Makeshift", "hooks.sh")
        if os.path.exists(makeshift_hook):
            subprocess.call(["sh", makeshift_hook])
            log(f"Installed hooks from {makeshift_hook}")
        else:
            log(f"[ERROR] Missing Makeshift hook: {makeshift_hook}")
    else:
        log(f"[ERROR] TGDKSafeTGDKSafeRoot not found at {SAFE_ROOT}")

def reboot_to_scope():
    log("Rebooting into TGDK roguebootloader scope...")
    subprocess.call(["reboot", "bootloader"])  # placeholder
    # or use a safer fallback:
    # os.system("svc power reboot bootloader")

def main():
    init_environment()
    log(f"Target file hash: {hash_file(TARGET_FILE)}")
    excessive_remake()
    install_hooks()
    reboot_to_scope()

if __name__ == "__main__":
    main()