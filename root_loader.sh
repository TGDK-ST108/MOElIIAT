# Step 3: Phi Biomatrix Enforcement
PHI=$(grep "phi_scalar=" olivia_scope/tgdkdef_iris.vec | cut -d '=' -f2 | tr -d ' ')
if [[ "$(echo "$PHI < 0.00001446" | bc)" -eq 1 || "$(echo "$PHI > 0.00001469" | bc)" -eq 1 ]]; then
  echo "[ROOT] Phi biomatrix out of secure range. Abort."
  echo "REJECTED" > "$ROOT_FLAG"
  exit 1
fi
echo "[ROOT] Phi biomatrix validated: $PHI"

echo "[ROOT] Flashing Magisk-patched boot image..."
fastboot flash boot "$BOOT_IMAGE"
fastboot reboot
