# Quick Start Guide

## Standard Workflow (Recommended)

Simply run these two commands in each phase directory:

### Phase 1: Central Manager
```bash
cd examples/phase1cm
terraform init
terraform apply -var-file=terraform.tfvars
```

### Phase 2: Aggregator
```bash
cd examples/phase2agg
terraform init
terraform apply -var-file=terraform.tfvars
```

### Phase 3: Collector
```bash
cd examples/phase3col
terraform init
terraform apply -var-file=terraform.tfvars
```

## That's It!

Everything runs automatically:
- ✅ VM creation
- ✅ Post-provisioning scripts
- ✅ Boot automation
- ✅ OS installation
- ✅ CLI configuration
- ✅ Shared secret setup
- ✅ Logging (in `logs/` directory)

No additional steps needed!
