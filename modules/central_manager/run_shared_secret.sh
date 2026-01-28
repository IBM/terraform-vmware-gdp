#!/bin/bash

IP="$1"
PASSWORD="$2"
SHARED_SECRET="$3"
LICENSE_KEY="${4:-}"

echo "🔐 Running shared secret setup with the following parameters:"
echo "   🔹 IP: $IP"
echo "   🔹 PASSWORD: $PASSWORD"
echo "   🔹 SHARED_SECRET: $SHARED_SECRET"
if [[ -n "$LICENSE_KEY" ]]; then
    echo "   🔹 LICENSE_KEY: [PROVIDED]"
else
    echo "   🔹 LICENSE_KEY: [NOT PROVIDED - will skip]"
fi
echo "-------------------------------------------"

# Validate input
if [[ -z "$IP" || -z "$PASSWORD" || -z "$SHARED_SECRET" ]]; then
    echo "❌ ERROR: One or more required input values are empty"
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run expect script with passed parameters
echo "🚀 Executing Expect script..."
expect "$SCRIPT_DIR/manual_shared_secret_setup.expect" "$IP" "$PASSWORD" "$SHARED_SECRET" "$LICENSE_KEY"