terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.5"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vcenter_username
  password             = var.vcenter_password
  vsphere_server       = var.vcenter_server
  allow_unverified_ssl = true
}

# Read instances from JSON file
locals {
  instances = jsondecode(file("${path.module}/instances.json"))
}

# Create central manager instances using for_each
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

