#!/bin/bash

IP="$1"
PASSWORD="$2"
SHARED_SECRET="$3"
GUARDIUM_CM_IP="$4"

echo "🔐 Running shared secret setup with the following parameters:"
echo "   🔹 IP: $IP"
echo "   🔹 PASSWORD: $PASSWORD"
echo "   🔹 SHARED_SECRET: $SHARED_SECRET"
echo "   🔹 GUARDIUM_CM_IP: $GUARDIUM_CM_IP"
echo "-------------------------------------------"

# Validate input
if [[ -z "$IP" || -z "$PASSWORD" || -z "$SHARED_SECRET" || -z "$GUARDIUM_CM_IP" ]]; then
    echo "❌ ERROR: One or more input values are empty"
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run expect script with passed parameters
echo "🚀 Executing Expect script..."
expect "$SCRIPT_DIR/manual_shared_secret_setup.expect" "$IP" "$PASSWORD" "$SHARED_SECRET" "$GUARDIUM_CM_IP"

