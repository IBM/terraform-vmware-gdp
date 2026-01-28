# Logging System

All Terraform runs and post-provisioning activities are automatically logged to files for easy troubleshooting and audit trails.

## Log Locations

All logs are stored in the `logs/` directory within each phase directory:

- `examples/phase1cm/logs/` - Central Manager logs
- `examples/phase2agg/logs/` - Aggregator logs  
- `examples/phase3col/logs/` - Collector logs

## Log Files

### Main Deployment Logs

When using `run_with_logging.sh`, a main log file is created:
- Format: `phase1cm_YYYYMMDD_HHMMSS.log`
- Format: `phase2agg_YYYYMMDD_HHMMSS.log`
- Format: `phase3col_YYYYMMDD_HHMMSS.log`

These logs contain:
- Terraform init output
- Terraform apply output
- All post-provisioning activities
- Timestamps for all operations

### Post-Provisioning Logs

Individual post-provisioning logs are created for each VM:
- Format: `post_provision_cm_YYYYMMDD_HHMMSS.log` (Central Manager)
- Format: `post_provision_<vm_name>_YYYYMMDD_HHMMSS.log` (Aggregator/Collector)

These logs contain:
- Boot menu automation
- OS installation wait times
- CLI configuration attempts
- Shared secret setup
- All script outputs with timestamps

## Usage

### Option 1: Use the Logging Wrapper Script (Recommended)

```bash
# Phase 1: Central Manager
cd examples/phase1cm
./run_with_logging.sh

# Phase 2: Aggregator
cd examples/phase2agg
./run_with_logging.sh

# Phase 3: Collector
cd examples/phase3col
./run_with_logging.sh
```

### Option 2: Manual Terraform Commands (Still Logged)

Even if you run `terraform apply` manually, post-provisioning logs are still created automatically:

```bash
cd examples/phase1cm
terraform init
terraform apply -var-file=terraform.tfvars
```

Post-provisioning logs will be created in `logs/` directory automatically.

## Log Format

Each log entry includes:
- **Timestamp**: `[YYYY-MM-DD HH:MM:SS]`
- **VM Identifier**: `[CM]`, `[agg-guard01]`, `[col-guard01]`, etc.
- **Message**: The actual log message

Example:
```
[2024-01-07 15:30:45] [CM] ⏳ Waiting 30 seconds for boot menu to load...
[2024-01-07 15:31:15] [CM] ⬇️ Sending boot keys...
[2024-01-07 15:31:20] [CM] ✅ boot_keys.py completed
```

## Viewing Logs

### View Latest Log
```bash
# Phase 1
ls -t examples/phase1cm/logs/*.log | head -1 | xargs tail -f

# Phase 2
ls -t examples/phase2agg/logs/*.log | head -1 | xargs tail -f

# Phase 3
ls -t examples/phase3col/logs/*.log | head -1 | xargs tail -f
```

### Search Logs
```bash
# Search for errors
grep -i error examples/phase2agg/logs/*.log

# Search for specific VM
grep "agg-guard01" examples/phase2agg/logs/*.log

# Search for timestamps
grep "2024-01-07 15:" examples/phase2agg/logs/*.log
```

## Log Retention

Logs are kept indefinitely. To clean up old logs:

```bash
# Remove logs older than 30 days
find examples/*/logs -name "*.log" -mtime +30 -delete
```

## Notes

- All logs are automatically created - no configuration needed
- Logs capture both stdout and stderr
- Logs are appended in real-time during execution
- Each VM gets its own post-provisioning log file
- Main deployment logs capture the entire Terraform run
