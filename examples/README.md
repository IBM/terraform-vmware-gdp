# Terraform VMware Guardium Deployment

Simple, automated deployment of Guardium VMs using Terraform.

## Quick Start

### Phase 1: Central Manager

```bash
cd examples/phase1cm
terraform init
terraform apply -var-file=terraform.tfvars
```

### Phase 2: Aggregator (Multiple VMs)

```bash
cd examples/phase2agg
terraform init
terraform apply -var-file=terraform.tfvars
```

### Phase 3: Collector (Multiple VMs)

```bash
cd examples/phase3col
terraform init
terraform apply -var-file=terraform.tfvars
```

## What Happens Automatically

When you run `terraform apply`, everything happens automatically:

1. **VM Creation**: Terraform creates the VM(s) in vSphere
2. **Post-Provisioning** (automatic):
   - Boot menu automation
   - OS installation (waits automatically)
   - CLI configuration via keystrokes
   - Shared secret setup
   - License configuration

3. **Logging** (automatic):
   - All post-provisioning activities are logged to `logs/` directory
   - Each VM gets its own log file with timestamps
   - Logs are created automatically - no configuration needed

## Configuration Files

### Phase 1 (Central Manager)
- `terraform.tfvars` - Contains all VM configuration

### Phase 2 & 3 (Aggregator/Collector)
- `terraform.tfvars` - Contains vCenter connection and timing settings
- `instances.json` - Contains VM-specific configurations (one entry per VM)

## Logs

All logs are automatically created in the `logs/` directory:

- **Post-provisioning logs**: `logs/post_provision_<vm_name>_YYYYMMDD_HHMMSS.log`
- **Main deployment logs** (if using `run_with_logging.sh`): `logs/phase1cm_YYYYMMDD_HHMMSS.log`

See [LOGGING.md](LOGGING.md) for detailed logging information.

## Notes

- Post-provisioning takes 30+ minutes per VM (installation + configuration)
- Keep your terminal session active during deployment
- All scripts run automatically - no manual intervention needed
- Logs are created automatically for troubleshooting

## Troubleshooting

If something goes wrong:
1. Check the logs in `logs/` directory
2. Each VM has its own log file with detailed timestamps
3. Logs show all steps: boot, installation, CLI config, shared secret setup
