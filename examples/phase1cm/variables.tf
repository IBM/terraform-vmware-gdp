# vCenter Connection Details
variable "vcenter_server" { type = string }
variable "vcenter_username" { type = string }
variable "vcenter_password" {
  type = string
  sensitive = true
}

# Automation Timing
variable "boot_menu_wait_seconds"    { type = number }
variable "installation_wait_minutes" { type = number }

