#!/bin/bash

# Post-provisioning script for collector
# This script reads directly from instances.json
# Usage: post_provision.sh <instances.json> <vm_name> <terraform.tfvars> [log_file]

INSTANCES_JSON="$1"
VM_NAME="$2"
BASE_TFVARS="${3:-terraform.tfvars}"
LOG_FILE="${4:-}"

if [[ -z "$INSTANCES_JSON" ]] || [[ -z "$VM_NAME" ]]; then
  echo "❌ ERROR: Usage: $0 <instances.json> <vm_name> [terraform.tfvars] [log_file]"
  exit 1
fi

if [[ ! -f "$INSTANCES_JSON" ]]; then
  echo "❌ ERROR: instances.json file not found: $INSTANCES_JSON"
  exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$SCRIPT_DIR"

# Function to log output
log_output() {
  if [[ -n "$LOG_FILE" ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$VM_NAME] $*" | tee -a "$LOG_FILE"
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$VM_NAME] $*"
  fi
}

# Extract instance data from JSON and create temporary tfvars for scripts that need it
TEMP_TFVARS=$(mktemp /tmp/terraform_${VM_NAME}_XXXXXX.tfvars)
trap "rm -f $TEMP_TFVARS" EXIT

# Merge instance data from JSON with base tfvars (vCenter connection and timing)
python3 <<EOF
import json
import sys
import os

vm_name = "$VM_NAME"
instances_file = "$INSTANCES_JSON"
base_tfvars = "$BASE_TFVARS"
output_file = "$TEMP_TFVARS"

# Load instances from JSON
with open(instances_file, 'r') as f:
    instances = json.load(f)

# Find the instance with matching vm_name
instance = None
for inst in instances:
    if inst.get('vm_name') == vm_name:
        instance = inst
        break

if not instance:
    print(f"ERROR: VM '{vm_name}' not found in {instances_file}", file=sys.stderr)
    sys.exit(1)

# Load base tfvars (vCenter connection and timing)
base_data = {}
if os.path.exists(base_tfvars):
    with open(base_tfvars, 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip().strip('"').strip("'")
                base_data[key] = value

# Merge: instance data overrides base data
merged = {**base_data, **instance}

# Write merged tfvars file
with open(output_file, 'w') as f:
    for key, value in merged.items():
        if isinstance(value, (int, float, bool)):
            f.write(f'{key} = {value}\n')
        elif isinstance(value, str):
            f.write(f'{key} = "{value}"\n')
        else:
            f.write(f'{key} = {value}\n')
EOF

if [ $? -ne 0 ]; then
  echo "❌ ERROR: Failed to extract data from instances.json"
  exit 1
fi

# Read wait times from base tfvars (vCenter connection and timing)
# Strip comments and extract numeric values
boot_wait=$(grep boot_menu_wait_seconds "$BASE_TFVARS" | sed 's/#.*$//' | awk -F'=' '{print $2}' | tr -d ' "' | tr -d "'")
install_minutes=$(grep installation_wait_minutes "$BASE_TFVARS" | sed 's/#.*$//' | awk -F'=' '{print $2}' | tr -d ' "' | tr -d "'")

# Validate numeric values
if ! [[ "$boot_wait" =~ ^[0-9]+$ ]]; then
  log_output "❌ ERROR: Invalid boot_menu_wait_seconds value: $boot_wait"
  exit 1
fi
if ! [[ "$install_minutes" =~ ^[0-9]+$ ]]; then
  log_output "❌ ERROR: Invalid installation_wait_minutes value: $install_minutes"
  exit 1
fi

log_output "⏳ Waiting $boot_wait seconds for boot menu to load..."
sleep "$boot_wait"

log_output "➡️ Running boot_keys.py with temporary tfvars..."
python3 "$MODULE_DIR/boot_keys.py" "$TEMP_TFVARS" 2>&1 | while IFS= read -r line; do log_output "$line"; done || { log_output "❌ boot_keys.py failed"; exit 1; }
log_output "✅ boot_keys.py completed"

log_output "⏳ Waiting $install_minutes minutes for OS installation to complete..."
log_output "⏰ This will take approximately $install_minutes minutes. Please wait..."
sleep $((install_minutes * 60))
log_output "✅ Installation wait period completed ($install_minutes minutes)"

# Extract values from JSON for CLI automation
VCENTER_SERVER=$(grep vcenter_server "$BASE_TFVARS" | awk '{print $3}' | tr -d '"')
VCENTER_USERNAME=$(grep vcenter_username "$BASE_TFVARS" | awk '{print $3}' | tr -d '"')
VCENTER_PASSWORD=$(grep vcenter_password "$BASE_TFVARS" | awk '{print $3}' | tr -d '"')

# CLI Keystroke automation
log_output "⌨️ Starting automate_guardium_input.ps1 with data from instances.json"

max_retries=15
retry_delay=60

for ((i=1; i<=max_retries; i++)); do
  log_output "🔁 Attempt $i: Sending CLI keystrokes to VM..."

  pwsh "$MODULE_DIR/automate_guardium_input.ps1" \
    -VCenterServer "$VCENTER_SERVER" \
    -Username "$VCENTER_USERNAME" \
    -Password "$VCENTER_PASSWORD" \
    -VMName "$VM_NAME" \
    -TerraformVarsPath "$TEMP_TFVARS"

  if [ $? -eq 0 ]; then
    log_output "✅ CLI configuration via keystrokes completed successfully."
    log_output "⏳ Waiting 5 minutes for Guardium to stabilize..."
    sleep 300

    # Extract values from JSON for shared secret script
    IP=$(grep network_interface_ip "$TEMP_TFVARS" | awk '{print $3}' | tr -d '"')
    PASSWORD=$(grep guardium_cli_password "$TEMP_TFVARS" | awk '{print $3}' | tr -d '"')
    SHARED_SECRET=$(grep guardium_shared_secret "$TEMP_TFVARS" | awk '{print $3}' | tr -d '"')
    GUARDIUM_CM_IP=$(grep guardium_central_manager_ip "$TEMP_TFVARS" | awk '{print $3}' | tr -d '"')

    log_output "🔍 Params for shared secret script:"
    log_output "    IP=$IP"
    log_output "    PASSWORD=$PASSWORD"
    log_output "    SHARED_SECRET=$SHARED_SECRET"
    log_output "    GUARDIUM_CM_IP=$GUARDIUM_CM_IP"

    bash "$MODULE_DIR/run_shared_secret.sh" "$IP" "$PASSWORD" "$SHARED_SECRET" "$GUARDIUM_CM_IP" 2>&1 | while IFS= read -r line; do log_output "$line"; done || {
      log_output "❌ Shared secret/register management automation failed"
      exit 1
    }

    log_output "✅ Shared secret and register management completed."
    break
  else
    log_output "❌ Attempt $i failed. Retrying in $retry_delay seconds..."
    sleep $retry_delay
  fi
done

