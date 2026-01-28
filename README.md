# Automated installation of GDP appliances on VMware

## Scope

The modules contained here automate installation of GDP appliances onto VMware.

The following are supported:

* Central Manager
* Aggregator
* Collector

For detailed instructions, including requirements and how to install them, see the [full instructions document](docs/FULL_INSTRUCTIONS.md).

## Summary of process

```
┌────────────────────────────────────────────────────┐
│                                                    │
│      Plan the installation, gather parameter       │
│                                                    │
└────────────────────────────────────────────────────┘
                          │
                          │
                          ▼
┌────────────────────────────────────────────────────┐
│                                                    │
│             Create the Central Manager             │
│                                                    │
└────────────────────────────────────────────────────┘
                          │
                          │
                          ▼
┌────────────────────────────────────────────────────┐
│                                                    │
│            Manually accept the  license            │
│                                                    │
└────────────────────────────────────────────────────┘
                          │
                          │
                          ▼
┌────────────────────────────────────────────────────┐
│                                                    │
│             Run script to convert to CM            │
│                                                    │
└────────────────────────────────────────────────────┘
                          │
                          │
                          ▼
┌────────────────────────────────────────────────────┐
│                                                    │
│               Create the Aggregators               │
│                                                    │
└────────────────────────────────────────────────────┘
                          │
                          │
                          ▼
┌────────────────────────────────────────────────────┐
│                                                    │
│               Create the Collectors                │
│                                                    │
└────────────────────────────────────────────────────┘
```

## Process flow

1. Connect to VMware. Plan the installation.
    * VMware info and structure
    * IP addresses and VM locations
    * ISO datastore info
    * VM parameters

2. Edit the parameters for the Central Manager.
2. Run the Terraform process to create a Central Manager.
3. Connect to the GDP appliance by web browser to accept GDP license.
4. Run the script to convert the GDP appliance to a CM.
4. Edit the parameters for the Aggregators.
5. Run the Terraform process to create the Aggregators.
6. Edit the parameters for the Collectors.
7. Run the Terraform process to create the Collectors.

## Prerequisites

### vSphere

* Ability to login to vSphere with privileges to create new VMs and access the required datastores.

### Linux

* A clone of the GitHub repository for the Terraform scripts.
* Expect
* Microsoft Powershell
* Python

The documentation here assumes you will be using a Linux computer to run the Terrafrom process. Instructions to install these items will vary depending upon which Linux distribution you are using.
See the [full instructions document](docs/FULL_INSTRUCTIONS.md) for complete details of the requirements.

### GDP

* License (only required if you are creating a central manager)

## Usage

### Central Manager

Create a GDP Central Manager on VMware:

```hcl
module "central_manager" {
  source = "../../modules/central_manager"
  for_each = { for inst in local.instances : inst.vm_name => inst }

  # vCenter Connection Details (from terraform.tfvars)
  vcenter_server   = var.vcenter_server
  vcenter_username = var.vcenter_username
  vcenter_password = var.vcenter_password

  # vCenter Environment Configuration (from instances.json)
  datacenter_name    = each.value.datacenter_name
  cluster_name       = each.value.cluster_name
  datastore_name     = each.value.datastore_name
  network_name       = each.value.network_name
  esxi_host_name     = each.value.esxi_host_name
  iso_datastore_name = each.value.iso_datastore_name

  # VM Configuration (from instances.json)
  vm_name        = each.value.vm_name
  vm_folder      = each.value.vm_folder
  vm_cpu_count   = each.value.vm_cpu_count
  vm_cpu_cores   = each.value.vm_cpu_cores
  vm_memory_mb   = each.value.vm_memory_mb
  vm_disk_gb     = each.value.vm_disk_gb
  guest_id       = "rhel8_64Guest"  # vCenter 7.x
  # guest_id     = "rhel9_64Guest" # vCenter 8.x

  # ISO Configuration (from instances.json)
  guardium_iso_path = each.value.guardium_iso_path
}
```


### Aggregator

Create a GDP Aggregator on VMware:

```hcl
module "aggregator" {
  source = "../../modules/aggregator"
  for_each = { for inst in local.instances : inst.vm_name => inst }

  # vCenter Connection Details (from terraform.tfvars)
  vcenter_server   = var.vcenter_server
  vcenter_username = var.vcenter_username
  vcenter_password = var.vcenter_password

  # vCenter Environment Configuration (from instances.json)
  datacenter_name    = each.value.datacenter_name
  cluster_name       = each.value.cluster_name
  datastore_name     = each.value.datastore_name
  network_name       = each.value.network_name
  esxi_host_name     = each.value.esxi_host_name
  iso_datastore_name = each.value.iso_datastore_name

  # VM Configuration (from instances.json)
  vm_name        = each.value.vm_name
  vm_folder      = each.value.vm_folder
  vm_cpu_count   = each.value.vm_cpu_count
  vm_cpu_cores   = each.value.vm_cpu_cores
  vm_memory_mb   = each.value.vm_memory_mb
  vm_disk_gb     = each.value.vm_disk_gb
  guest_id       = "rhel8_64Guest"  # vCenter 7.x
  # guest_id     = "rhel9_64Guest" # vCenter 8.x

  # ISO Configuration (from instances.json)
  guardium_iso_path = each.value.guardium_iso_path
}
```


### Collector

Create a GDP Collector on VMware:

```hcl
module "collector" {
  source = "../../modules/collector"
  for_each = { for inst in local.instances : inst.vm_name => inst }

  # vCenter Connection Details (from terraform.tfvars)
  vcenter_server   = var.vcenter_server
  vcenter_username = var.vcenter_username
  vcenter_password = var.vcenter_password

  # vCenter Environment Configuration (from instances.json)
  datacenter_name    = each.value.datacenter_name
  cluster_name       = each.value.cluster_name
  datastore_name     = each.value.datastore_name
  network_name       = each.value.network_name
  esxi_host_name     = each.value.esxi_host_name
  iso_datastore_name = each.value.iso_datastore_name

  # VM Configuration (from instances.json)
  vm_name        = each.value.vm_name
  vm_folder      = each.value.vm_folder
  vm_cpu_count   = each.value.vm_cpu_count
  vm_cpu_cores   = each.value.vm_cpu_cores
  vm_memory_mb   = each.value.vm_memory_mb
  vm_disk_gb     = each.value.vm_disk_gb
  guest_id       = "rhel8_64Guest"  # vCenter 7.x
  # guest_id     = "rhel9_64Guest" # vCenter 8.x

  # ISO Configuration (from instances.json)
  guardium_iso_path = each.value.guardium_iso_path
}
```
## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Support

For issues and questions:
- Create an issue in this repository
- Contact the maintainers listed in [MAINTAINERS.md](MAINTAINERS.md)

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

```text
#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#
```

## Authors

Module is maintained by IBM with help from [these awesome contributors](https://github.com/IBM/terraform-guardium-datastore-va/graphs/contributors).
