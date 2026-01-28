#!/bin/bash

# Wrapper script that runs terraform with full logging
# All output will be logged to logs/ directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Create logs directory
LOGS_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOGS_DIR"

# Generate log filename with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOGS_DIR/phase1cm_${TIMESTAMP}.log"

echo "📝 Logging all output to: $LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"
echo "Phase 1: Central Manager Deployment" | tee -a "$LOG_FILE"
echo "Started: $(date)" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"
echo ""

# Run terraform init and apply with logging
{
  echo "🚀 Starting Terraform init..."
  terraform init 2>&1
  
  echo ""
  echo "🚀 Starting Terraform apply..."
  terraform apply -var-file=terraform.tfvars 2>&1
  
  echo ""
  echo "=========================================="
  echo "Completed: $(date)"
  echo "=========================================="
} | tee -a "$LOG_FILE"

EXIT_CODE=${PIPESTATUS[0]}

if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ Deployment completed successfully. Log saved to: $LOG_FILE" | tee -a "$LOG_FILE"
else
  echo "❌ Deployment failed. Check log: $LOG_FILE" | tee -a "$LOG_FILE"
fi

exit $EXIT_CODE
