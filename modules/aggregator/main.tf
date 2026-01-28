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

data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "iso_datastore" {
  name          = var.iso_datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.esxi_host_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "guardium" {
  name             = var.vm_name
  folder           = var.vm_folder != "" ? var.vm_folder : null
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id

  num_cpus             = var.vm_cpu_count
  num_cores_per_socket = var.vm_cpu_cores
  memory               = var.vm_memory_mb
  guest_id             = var.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = var.vm_disk_gb
    eagerly_scrub    = false
    thin_provisioned = true
  }

  cdrom {
    client_device = false
    datastore_id  = data.vsphere_datastore.iso_datastore.id
    path          = var.guardium_iso_path
  }

  wait_for_guest_net_timeout = 0
}

# Post-provisioning automation
resource "null_resource" "post_provision" {
  depends_on = [vsphere_virtual_machine.guardium]

  triggers = {
    vm_id = vsphere_virtual_machine.guardium.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Create logs directory and set log file
      LOGS_DIR="${path.root}/logs"
      mkdir -p "$${LOGS_DIR}"
      VM_NAME="${vsphere_virtual_machine.guardium.name}"
      TIMESTAMP=`date +%Y%m%d_%H%M%S`
      LOG_FILE="$${LOGS_DIR}/$${TIMESTAMP}_$${VM_NAME}.log"
      # Run post-provisioning - reads directly from instances.json
      # Use the actual VM name from the Terraform resource (matches JSON)
      bash "${path.module}/post_provision.sh" "${path.root}/instances.json" "${vsphere_virtual_machine.guardium.name}" "${path.root}/terraform.tfvars" "$${LOG_FILE}" 2>&1 | tee -a "$${LOG_FILE}"
    EOT
  }
}

