#!/bin/bash
# modules/central_manager/run_guardium_phase2.sh (VMware Version)
# Wrapper script for Guardium Phase 2 configuration
# Reads values from instances.json automatically, or accepts command-line arguments

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to find phase1cm examples directory
find_phase1cm_dir() {
    local search_paths=(
        "$(dirname "$SCRIPT_DIR")/../../examples/phase1cm"
        "$(dirname "$SCRIPT_DIR")/../examples/phase1cm"
        "./examples/phase1cm"
        "../examples/phase1cm"
        "../../examples/phase1cm"
        "/examples/phase1cm"
    )
    
    for path in "${search_paths[@]}"; do
        if [ -d "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    return 1
}

# Setup logging
PHASE1CM_DIR=$(find_phase1cm_dir)
if [ -n "$PHASE1CM_DIR" ]; then
    LOGS_DIR="$PHASE1CM_DIR/logs"
    mkdir -p "$LOGS_DIR"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    LOG_FILE="$LOGS_DIR/${TIMESTAMP}_phase2.log"
    
    # Function to log output (both to console and file)
    log_output() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
    }
    
    # Log script start
    {
        echo "=========================================="
        echo "GUARDIUM PHASE 2 CONFIGURATION SCRIPT"
        echo "Started: $(date)"
        echo "Log file: $LOG_FILE"
        echo "=========================================="
    } | tee -a "$LOG_FILE"
else
    # Fallback if phase1cm directory not found
    LOG_FILE=""
    log_output() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    }
    log_output "⚠️  Warning: Could not find phase1cm examples directory. Logging to console only."
fi

# Function to find instances.json
find_instances_json() {
    local search_paths=(
        "$(dirname "$SCRIPT_DIR")/../../examples/phase1cm/instances.json"
        "$(dirname "$SCRIPT_DIR")/../examples/phase1cm/instances.json"
        "./examples/phase1cm/instances.json"
        "../examples/phase1cm/instances.json"
        "../../examples/phase1cm/instances.json"
        "/examples/phase1cm/instances.json"
        "./instances.json"
        "../instances.json"
    )
    
    for path in "${search_paths[@]}"; do
        if [ -f "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    return 1
}

# Function to extract values from instances.json
extract_from_json() {
    local json_file="$1"
    local vm_name="${2:-}"
    
    if [ ! -f "$json_file" ]; then
        return 1
    fi
    
    # Use Python to extract values (more reliable than jq which might not be installed)
    python3 <<EOF
import json
import sys

try:
    with open("$json_file", 'r') as f:
        instances = json.load(f)
    
    # If vm_name specified, find that instance, otherwise use first
    instance = None
    if "$vm_name":
        for inst in instances:
            if inst.get('vm_name') == "$vm_name":
                instance = inst
                break
    else:
        instance = instances[0] if instances else None
    
    if not instance:
        sys.exit(1)
    
    ip = instance.get('network_interface_ip', '')
    password = instance.get('guardium_cli_password', '')
    shared_secret = instance.get('guardium_shared_secret', '')
    
    print(f"{ip}|{password}|{shared_secret}")
except Exception as e:
    sys.exit(1)
EOF
}

# Parse arguments or read from instances.json
# Default behavior: read from instances.json
# Optional: override with command-line arguments

INSTANCES_JSON=$(find_instances_json)

if [ $# -eq 3 ]; then
    # All arguments provided - use them as override
    IP="$1"
    FINAL_PASSWORD="$2"
    SHARED_SECRET="$3"
    log_output "📋 Using provided command-line values (override):"
    log_output "   IP: $IP"
    log_output "   Password: [HIDDEN]"
    log_output "   Shared Secret: $SHARED_SECRET"
elif [ -n "$INSTANCES_JSON" ]; then
    # Read from instances.json (default behavior)
    log_output "🔍 Reading parameters from instances.json..."
    log_output "✅ Found instances.json at: $INSTANCES_JSON"
    
    # Extract values - use first instance if no vm_name specified
    VALUES=$(extract_from_json "$INSTANCES_JSON" "")
    if [ $? -ne 0 ] || [ -z "$VALUES" ]; then
        log_output "❌ Error: Failed to extract values from instances.json"
        exit 1
    fi
    
    IFS='|' read -r IP FINAL_PASSWORD SHARED_SECRET <<< "$VALUES"
    
    if [ -z "$IP" ] || [ -z "$FINAL_PASSWORD" ] || [ -z "$SHARED_SECRET" ]; then
        log_output "❌ Error: Missing required values in instances.json"
        log_output "   Required: network_interface_ip, guardium_cli_password, guardium_shared_secret"
        exit 1
    fi
    
    log_output "📋 Using values from instances.json:"
    log_output "   IP: $IP"
    log_output "   Password: [HIDDEN]"
    log_output "   Shared Secret: $SHARED_SECRET"
else
    log_output "❌ Error: instances.json not found and no arguments provided."
    log_output ""
    log_output "Usage: $0 [<IP> <password> <shared_secret>]"
    log_output "   Default: Reads from examples/phase1cm/instances.json"
    log_output "   Override: Provide IP, password, and shared_secret as arguments"
    log_output ""
    log_output "Example: $0 9.80.59.179 'Welcome2Guardium!' 'guard'"
    log_output "Note: Add single quotation marks around complex passwords"
    exit 1
fi

log_output "=========================================="
log_output "GUARDIUM PHASE 2 CONFIGURATION (VMware)"
log_output "IP: $IP"
log_output "Time: $(date)"
log_output "=========================================="

# Look for expect script in the module directory
EXPECT_SCRIPT="$SCRIPT_DIR/wait_for_guardium_phase2.expect"

# Try multiple locations for expect script
EXPECT_LOCATIONS=(
  "$SCRIPT_DIR/wait_for_guardium_phase2.expect"
  "$(dirname "$SCRIPT_DIR")/central_manager/wait_for_guardium_phase2.expect"
)

EXPECT_SCRIPT_FOUND=""
for location in "${EXPECT_LOCATIONS[@]}"; do
  if [ -f "$location" ]; then
    EXPECT_SCRIPT_FOUND="$location"
    log_output "✅ Found expect script at: $EXPECT_SCRIPT_FOUND"
    break
  fi
done

if [ -z "$EXPECT_SCRIPT_FOUND" ]; then
    log_output "❌ Error: Expect script 'wait_for_guardium_phase2.expect' not found in any of these locations:"
    for location in "${EXPECT_LOCATIONS[@]}"; do
      log_output "  - $location"
    done
    log_output ""
    log_output "Please ensure the expect script exists or create it."
    exit 1
fi

# Make sure expect script is executable
chmod +x "$EXPECT_SCRIPT_FOUND"

# Test connectivity first
log_output "🔍 Testing connectivity to $IP:22..."
if ! timeout 10 bash -c "echo > /dev/tcp/$IP/22" 2>/dev/null; then
    if ! nc -z -w10 "$IP" 22 >/dev/null 2>&1; then
        log_output "❌ Error: Cannot reach $IP on port 22"
        log_output "Please ensure:"
        log_output "  1. The VM is powered on"
        log_output "  2. SSH service is running on the VM"
        log_output "  3. Network connectivity is available"
        exit 1
    fi
fi

log_output "✅ Connection test passed. Starting Phase 2 configuration..."

# Run the expect script and capture output
log_output "🚀 Executing expect script: $EXPECT_SCRIPT_FOUND"
if [ -n "$LOG_FILE" ]; then
    # With logging - capture exit code properly
    "$EXPECT_SCRIPT_FOUND" "$IP" "$FINAL_PASSWORD" "$SHARED_SECRET" 2>&1 | tee -a "$LOG_FILE"
    EXPECT_EXIT_CODE=${PIPESTATUS[0]}
else
    # Without logging (fallback)
    "$EXPECT_SCRIPT_FOUND" "$IP" "$FINAL_PASSWORD" "$SHARED_SECRET"
    EXPECT_EXIT_CODE=$?
fi

if [ $EXPECT_EXIT_CODE -eq 0 ]; then
    log_output "=========================================="
    log_output "✅ Phase 2 configuration completed successfully!"
    log_output "Guardium Central Manager is now fully configured."
    log_output "Ready for Phase 2 (Aggregators) deployment."
    log_output "=========================================="
    if [ -n "$LOG_FILE" ]; then
        log_output "Log file saved to: $LOG_FILE"
    fi
    exit 0
else
    log_output "=========================================="
    log_output "❌ Phase 2 configuration failed!"
    log_output "Please check the logs and try again."
    log_output ""
    log_output "Manual steps:"
    log_output "  ssh cli@$IP"
    log_output "  store unit type manager"
    log_output "  store system shared secret $SHARED_SECRET"
    log_output "=========================================="
    if [ -n "$LOG_FILE" ]; then
        log_output "Log file saved to: $LOG_FILE"
    fi
    exit 1
fi
