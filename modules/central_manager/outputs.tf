output "vm_name" {
  description = "The name of the deployed Guardium VM"
  value       = vsphere_virtual_machine.guardium.name
}

output "vm_power_state" {
  description = "Power state of the Guardium VM"
  value       = vsphere_virtual_machine.guardium.power_state
}

output "vm_ip_address" {
  description = "The IP address of the Guardium VM (if available)"
  value       = vsphere_virtual_machine.guardium.default_ip_address
}

output "vm_guest_os" {
  description = "Guest OS ID of the Guardium VM"
  value       = vsphere_virtual_machine.guardium.guest_id
}

output "vm_cpu" {
  description = "Number of vCPUs assigned to the Guardium VM"
  value       = vsphere_virtual_machine.guardium.num_cpus
}

output "vm_memory_mb" {
  description = "Memory assigned to the Guardium VM in MB"
  value       = vsphere_virtual_machine.guardium.memory
}

output "vm_disk_size_gb" {
  description = "Disk size of the Guardium VM in GB"
  value       = vsphere_virtual_machine.guardium.disk.0.size
}

output "vm_id" {
  description = "The UUID of the VM"
  value       = vsphere_virtual_machine.guardium.id
}

