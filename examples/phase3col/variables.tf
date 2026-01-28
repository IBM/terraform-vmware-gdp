# vCenter Connection Details (required - used by provider)
variable "vcenter_server" { 
  type = string
  description = "vCenter server address"
}
variable "vcenter_username" { 
  type = string
  description = "vCenter username"
}
variable "vcenter_password" {
  type = string
  description = "vCenter password"
  sensitive = true
}

# Automation Timing (required - used in post-provisioning)
variable "boot_menu_wait_seconds" { 
  type = number
  description = "Seconds to wait for boot menu to load"
}
variable "installation_wait_minutes" { 
  type = number
  description = "Minutes to wait for OS installation to complete"
}

# Note: All other variables (datacenter_name, cluster_name, vm_name, etc.)
# are read from instances.json and passed to modules via each.value
# They do not need to be declared here as root-level variables

