# Terraform VMware Guardium Deployment

Automated deployment of IBM Guardium VMs (Central Manager, Aggregators, and Collectors) on VMware vSphere using Terraform.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Usage](#usage)
- [Logging](#logging)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)

## Prerequisites

### System Requirements

- **Operating System**: Linux (RHEL 8/9, Ubuntu 20.04+, or similar)
- **Minimum Resources**: 4GB RAM, 10GB free disk space
- **Network**: Access to vCenter server and internet (for Terraform providers)

### Required Software

#### 1. Terraform (Required)

Install Terraform version 1.0 or later:

**For RHEL/CentOS/Fedora:**
```bash
# Install using yum/dnf
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum install -y terraform

# Verify installation
terraform version
```

**For Ubuntu/Debian:**
```bash
# Install using apt
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify installation
terraform version
```

**Manual Installation (All Linux):**
```bash
# Download Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip

# Move to PATH
sudo mv terraform /usr/local/bin/
terraform version
```

#### 2. Python 3 (Required)

Install Python 3.8 or later:

**For RHEL/CentOS/Fedora:**
```bash
sudo yum install -y python3 python3-pip
python3 --version
```

**For Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y python3 python3-pip
python3 --version
```

**Install required Python packages:**
```bash
pip3 install --user python-hcl2
# Or system-wide
sudo pip3 install python-hcl2
# Verify installation
python3 -c "import hcl2; print(hcl2.__version__)"

```

#### 3. PowerShell Core (Required)

Install PowerShell Core (pwsh) for VM keystroke automation:

**For RHEL/CentOS/Fedora 8/9:**
```bash
# Register Microsoft repository
curl -sSL https://packages.microsoft.com/config/rhel/8/prod.repo | sudo tee /etc/yum.repos.d/microsoft-prod.repo

# Install PowerShell
sudo yum install -y powershell

# Verify installation
pwsh --version
```

**For Ubuntu/Debian:**
```bash
# Download and install
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install -y powershell

# Verify installation
pwsh --version
```

**Manual Installation (All Linux):**
```bash
# Download PowerShell Core
wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell-7.4.0-linux-x64.tar.gz
mkdir -p ~/powershell
tar -xzf powershell-7.4.0-linux-x64.tar.gz -C ~/powershell
sudo ln -s ~/powershell/pwsh /usr/local/bin/pwsh

# Verify installation
pwsh --version
```

**Install VMware PowerCLI Module:**
```bash
pwsh -Command "Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force -AllowClobber"
```

#### 4. Expect (Required)

Install Expect for automated SSH interactions:

**For RHEL/CentOS/Fedora:**
```bash
sudo yum install -y expect
expect --version
```

**For Ubuntu/Debian:**
```bash
sudo apt install -y expect
expect --version
```

#### 5. Additional Tools (Recommended)

**netcat (nc)** - For connectivity testing:
```bash
# RHEL/CentOS/Fedora
sudo yum install -y nc

# Ubuntu/Debian
sudo apt install -y netcat
```

**jq** - For JSON parsing (optional but useful):
```bash
# RHEL/CentOS/Fedora
sudo yum install -y jq

# Ubuntu/Debian
sudo apt install -y jq
```

**git** - For version control:
```bash
# RHEL/CentOS/Fedora
sudo yum install -y git

# Ubuntu/Debian
sudo apt install -y git
```

### Access Requirements

1. **vCenter Server Access:**
   - vCenter server address/URL
   - Valid credentials with permissions to:
     - Create VMs
     - Configure VM resources
     - Access datastores
     - Attach ISO files

2. **Guardium ISO:**
   - Guardium ISO file uploaded to a vSphere datastore
   - Know the full path to the ISO in the datastore

3. **Network Configuration:**
   - IP addresses for each VM
   - Network gateway, DNS servers
   - Network mask/prefix

## Installation

### 1. Clone or Download the Repository

```bash
git clone <repository-url>
cd terraform-vmware-gdp
```

Or download and extract the ZIP file.

### 2. Verify Prerequisites

Run this script to verify all prerequisites are installed:

```bash
#!/bin/bash
echo "Checking prerequisites..."
echo "Terraform: $(terraform version 2>&1 | head -1 || echo 'NOT INSTALLED')"
echo "Python 3: $(python3 --version 2>&1 || echo 'NOT INSTALLED')"
echo "PowerShell: $(pwsh --version 2>&1 || echo 'NOT INSTALLED')"
echo "Expect: $(expect --version 2>&1 | head -1 || echo 'NOT INSTALLED')"
echo "hcl2 Python module: $(python3 -c 'import hcl2; print("OK")' 2>&1 || echo 'NOT INSTALLED')"
echo "VMware.PowerCLI: $(pwsh -Command 'Get-Module -ListAvailable VMware.PowerCLI' 2>&1 | grep -q VMware && echo 'OK' || echo 'NOT INSTALLED')"
```

### 3. Configure Permissions

Ensure scripts are executable:

```bash
find modules -name "*.sh" -exec chmod +x {} \;
find modules -name "*.expect" -exec chmod +x {} \;
find modules -name "*.py" -exec chmod +x {} \;
```

## Quick Start

### Phase 1: Deploy Central Manager

```bash
cd examples/phase1cm

# Edit configuration
vi terraform.tfvars  # Update with your values
vi instances.json    # Configure each collector VM

# Initialize Terraform
terraform init

# Review plan
terraform plan -var-file=terraform.tfvars

# Deploy
terraform apply -var-file=terraform.tfvars
```

### Phase 2: Deploy Aggregators (After Phase 1 completes)

```bash
cd examples/phase2agg

# Edit configuration
vi terraform.tfvars  # Update vCenter connection
vi instances.json    # Configure each aggregator VM

# Initialize and deploy
terraform init
terraform apply -var-file=terraform.tfvars
```

### Phase 3: Deploy Collectors (After Phase 1 completes)

```bash
cd examples/phase3col

# Edit configuration
vi terraform.tfvars  # Update vCenter connection
vi instances.json    # Configure each collector VM

# Initialize and deploy
terraform init
terraform apply -var-file=terraform.tfvars
```

## Configuration

### Phase 1 (Central Manager)

Edit `examples/phase1cm/terraform.tfvars`:

```hcl
# vCenter Connection
vcenter_server   = "vcenter.example.com"
vcenter_username = "administrator@vsphere.local"
vcenter_password = "YourPassword123!"

# VM Configuration (or edit examples/phase1cm/instances.json)
vm_name          = "cm-guard01"
network_interface_ip = "9.80.59.179"
# ... other settings
```

### Phase 2 & 3 (Aggregator/Collector)

**terraform.tfvars** - Contains vCenter connection and timing:
```hcl
vcenter_server   = "vcenter.example.com"
vcenter_username = "administrator@vsphere.local"
vcenter_password = "YourPassword123!"
boot_menu_wait_seconds = 30
installation_wait_minutes = 25
```

**instances.json** - Contains per-VM configuration:
```json
[
  {
    "vm_name": "agg-guard01",
    "network_interface_ip": "9.80.59.176",
    "guardium_cli_password": "MyPassword2020!",
    "guardium_shared_secret": "guard",
    "guardium_central_manager_ip": "9.80.59.179",
    ...
  }
]
```

See [TERRAFORM_GUIDE.md](TERRAFORM_GUIDE.md) for detailed configuration instructions.

## Usage

### Deployment Workflow

1. **Phase 1 - Central Manager** (Run first)
   - Deploys the Central Manager VM
   - Automatically configures Guardium
   - Sets up shared secret
   - Note the Central Manager IP address from outputs

2. **Phase 2 - Aggregators** (After Phase 1)
   - Deploy one or more Aggregator VMs
   - Each VM is automatically registered with the Central Manager
   - Configured with shared secret

3. **Phase 3 - Collectors** (After Phase 1)
   - Deploy one or more Collector VMs
   - Each VM is automatically registered with the Central Manager
   - Configured with shared secret

### Viewing Outputs

After deployment, view VM information:

```bash
terraform output
```

This shows:
- VM names
- IP addresses
- Power states
- Resource details (CPU, memory, disk)

### Logs

All deployment activities are logged automatically:

- **Location**: `examples/<phase>/logs/`
- **Format**: `YYYYMMDD_HHMMSS_<vm_name>.log`
- **Contents**: Complete post-provisioning activity with timestamps

Example log files:
- `examples/phase1cm/logs/20260109_143022_cm-guard01.log`
- `examples/phase2agg/logs/20260109_150530_agg-guard01.log`

### Phase 2 Configuration (Central Manager)

After Phase 1 completes, configure the Central Manager for Phase 2:

```bash
cd modules/central_manager
./run_guardium_phase2.sh
```

This script:
- Reads configuration from `examples/phase1cm/instances.json`
- Connects to the Central Manager
- Configures unit type to "manager"
- Sets up shared secret
- Verifies network configuration

## Troubleshooting

### Prerequisites Not Found

**Issue**: `terraform: command not found`
```bash
# Verify installation
which terraform
terraform version

# If not installed, follow installation steps above
```

**Issue**: `python3: command not found`
```bash
# Install Python 3
sudo yum install python3  # RHEL/CentOS
sudo apt install python3  # Ubuntu/Debian
```

**Issue**: `pwsh: command not found`
```bash
# Install PowerShell Core (see installation section above)
# Verify installation
pwsh --version
```

**Issue**: `ModuleNotFoundError: No module named 'hcl2'`
```bash
pip3 install --user hcl2
# Or system-wide
sudo pip3 install hcl2
```

**Issue**: PowerShell can't find VMware.PowerCLI module
```bash
pwsh -Command "Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force -AllowClobber"
pwsh -Command "Import-Module VMware.PowerCLI"
```

### Terraform Issues

**Issue**: `terraform init` fails
```bash
# Check internet connectivity
ping google.com

# Clear cache and retry
rm -rf .terraform .terraform.lock.hcl
terraform init
```

**Issue**: Provider download fails
```bash
# Check proxy settings if behind firewall
export HTTP_PROXY=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080
terraform init
```

### VM Creation Issues

**Issue**: Authentication failed to vCenter
```bash
# Verify credentials in terraform.tfvars
# Test vCenter connection manually
# Check if account is locked or requires MFA
```

**Issue**: Datastore/cluster not found
```bash
# Verify names match exactly (case-sensitive)
# List available resources in vSphere
# Update terraform.tfvars with correct names
```

### Post-Provisioning Issues

**Issue**: Scripts fail with permission denied
```bash
# Make scripts executable
chmod +x modules/*/*.sh
chmod +x modules/*/*.expect
chmod +x modules/*/*.py
```

**Issue**: Can't connect to VM via SSH
```bash
# Wait for VM to fully boot (5-10 minutes after creation)
# Verify network configuration
# Check firewall rules
# Verify SSH service is running on VM
```

**Issue**: Logs show timeout errors
```bash
# Check logs in examples/<phase>/logs/
# Increase wait times in terraform.tfvars:
#   boot_menu_wait_seconds = 60
#   installation_wait_minutes = 30
```

### Check Logs

Always check logs first when troubleshooting:

```bash
# View latest log
ls -lt examples/phase1cm/logs/ | head -5

# View specific log
tail -f examples/phase1cm/logs/20260109_143022_cm-guard01.log
```

## Project Structure

```
terraform-vmware-gdp/
├── examples/
│   ├── phase1cm/          # Central Manager deployment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   └── instances.json
│   ├── phase2agg/         # Aggregator deployment
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── instances.json
│   └── phase3col/         # Collector deployment
│       ├── main.tf
│       ├── terraform.tfvars
│       └── instances.json
├── modules/
│   ├── central_manager/   # Central Manager module
│   ├── aggregator/        # Aggregator module
│   └── collector/         # Collector module
├── README.md              # This file
└── TERRAFORM_GUIDE.md     # Detailed deployment guide
```

## Additional Resources

- [Detailed Terraform Guide](TERRAFORM_GUIDE.md) - Comprehensive deployment instructions
- [Logging Documentation](examples/LOGGING.md) - Detailed logging information
- [Terraform Documentation](https://www.terraform.io/docs)
- [VMware vSphere Provider](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs)

## Known Issues and Version Differences

### DNS Resolver Command Inconsistency

There is a known inconsistency in the Guardium CLI DNS resolver configuration command between versions.

**Version 12.1**
```bash
store network resolver 9.0.0.1 9.0.0.2
```
**Version 12.2**
```bash

store network resolvers 9.0.0.1 9.0.0.2
```
Important:
Version 12.2 requires the plural form resolvers (with s).
This difference can cause automation failures if not handled explicitly.
Required File Update
The change must be applied in the following file:
```bash
modules/automate_guardium_input.ps1
```
update the line 208 
```bash
 @{ cmd = "store network resolver $dns1 $dns2"; wait = 15 },
```


## Support

For issues and questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review logs in `examples/<phase>/logs/`
3. Verify all prerequisites are installed correctly
4. Check Terraform and vSphere provider documentation

## License

[Add your license information here]
