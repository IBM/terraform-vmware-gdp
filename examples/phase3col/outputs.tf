output "vm_names" {
  description = "The names of all deployed Guardium VMs"
  value       = { for k, v in module.collector : k => v.vm_name }
}

output "vm_power_states" {
  description = "Power states of all Guardium VMs"
  value       = { for k, v in module.collector : k => v.vm_power_state }
}

output "vm_ip_addresses" {
  description = "The IP addresses of all Guardium VMs (from instances.json)"
  value       = { for k, v in module.collector : k => [for inst in local.instances : inst.network_interface_ip if inst.vm_name == k][0] }
}

output "vm_details" {
  description = "Complete details of all deployed Guardium VMs"
  value = {
    for k, v in module.collector : k => {
      vm_name       = v.vm_name
      vm_ip_address = [for inst in local.instances : inst.network_interface_ip if inst.vm_name == k][0]
      vm_power_state = v.vm_power_state
      vm_cpu        = v.vm_cpu
      vm_memory_mb  = v.vm_memory_mb
      vm_disk_size_gb = v.vm_disk_size_gb
    }
  }
}