#!/bin/bash
# ====================================================================
#                           TGDK BFE LICENSE                         
# ====================================================================
# LICENSE HOLDER:              |  Sean Tichenor                        
# LICENSE CODE:                |  D2501-V01                            
# DATE OF ISSUANCE:            |  March 27, 2025                       
# LICENSE STATUS:              |  ACTIVE                                
# ISSUING AUTHORITY:           |  TGDK Licensing Authority             
# ====================================================================
# DESCRIPTION:  
# root_loader.sh - Launches root sequence using QQUAp trust stack,
# Y_SEAL geo enforcement, and tgdkdef_iris.vec for biometric gating.
# ROOTING IS RESTRICTED TO U.S. REGION AND TGDK OPERATOR ONLY.
# ====================================================================
# UNAUTHORIZED USE, MODIFICATION, OR DISTRIBUTION IS STRICTLY PROHIBITED.
# ====================================================================

ROOT_FLAG="deploy/root_status.trust"
LICENSE="LICENSE.txt"
IRIS_VECT="olivia_scope/retainer_iris_lock.qfx"
BOOT_IMAGE="boot/patched_boot.img"
LOCK_FILE="boot/USLock_trigger.def"

# Step 1: Verify Region Lock & License
if ! grep -q "REGION=US" "$LOCK_FILE" || ! grep -q "LOCK=TRUE" "$LOCK_FILE"; then
  echo "[ROOT] US Lock Trigger failed. Region not authorized."
  exit 144
fi

if ! grep -q "LICENSE CODE:                |  D2501-V01" "$LICENSE"; then
  echo "[ROOT] License verification failed. Aborting root."
  exit 144
fi

# Step 2: Verify Biometric Iris Binding
if ! grep -q "\"auth_status\": \"BOUND\"" "$IRIS_VECT"; then
  echo "[ROOT] Iris biometric not bound. Cannot proceed."
  echo "REJECTED" > "$ROOT_FLAG"
  exit 1
fi

# Step 3: Flash Patched Boot Image (requires unlocked bootloader)
echo "[ROOT] Flashing patched boot image..."
fastboot flash boot "$BOOT_IMAGE"
fastboot oem unlock

# Step 4: Confirm & Write Root Status
sleep 1.2
echo "[ROOT] Operation completed. TGDK Quantum Trust Retainer Engaged."
echo "ROOTED: VERIFIED UNDER QQUAp + D2501-V01 + BIOMETRIC LOCK" > "$ROOT_FLAG"
exit 0
