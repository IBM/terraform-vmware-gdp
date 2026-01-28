# Create GDP Central Manager for VMware

## Introduction

This module creates a GDP Central Manager on VMware.

## Parameters

All parameters must be modified in the terraform.tfvars and instances.json files. See the [documentation](../../examples/phase1cm/README.md) in the example for instructions.

### terraform.tfvars

| Name | Comment | 
| --- | --- | 
| vcenter_server | URL of your vSphere | 
| vcenter_username | Username for user that will perform all VM actions | 
| vcenter_password | Password of the user | 

### instances.json

| Name | Comment | 
| --- | --- | 
| vm_name | What to name the VM that will be created | 
| system_hostname | The hostname for the VM -- should be the same as vm_name |
| network_interface_ip | IP address of the VM |
| system_domain | Domain of the VM |
| network_interface_mask | Leave this as-is |
| network_routes_defaultroute | Default rout of the network |
| network_resolvers1 | DNS server for the appliance |
| network_resolvers2 | DNS server for the appliance |
| system_clock_timezone | GDP timezone |
| datacenter_name | Name of the vSphere data center |
| cluster_name | Name group of VMs |
| datastore_name | Name of the vSphere datastore | 
| network_name | Name of the vSphere network | 
| iso_datastore_name | Name of ISO in the datastore |
| vm_folder | Name of subfolder for VM if exists |
| vm_cpu_count | CPUs |
| vm_cpu_cores | Cores |
| vm_memory_mb | Memory |
| vm_disk_gb | Disk |
| guardium_iso_path | Path to the ISO |
| guardium_cli_default_password | Default password for connecting to GDP CLI |
| guardium_cli_password | New password that will be created during the process -- you should change this |
| guardium_shared_secret | Shared secret for registering appliances |
| guardium_license_key | Enter your GDP license here |

## Manual steps

After the Terraform process runs, it will create a stand-alone Aggregator. This must be manually converted to a Central Manager. See the [documentation](../../examples/phase1cm/README.md) in the example for instructions.
