# vCenter Connection Details
variable "vcenter_server" {
  type        = string
  description = "vCenter server address"
}

variable "vcenter_username" {
  type        = string
  description = "vCenter username"
}

variable "vcenter_password" {
  type        = string
  description = "vCenter password"
  sensitive   = true
}

# vCenter Environment Configuration
variable "datacenter_name" {
  type        = string
  description = "Name of the datacenter"
}

variable "cluster_name" {
  type        = string
  description = "Name of the compute cluster"
}

variable "datastore_name" {
  type        = string
  description = "Name of the datastore where VM will be installed"
}

variable "network_name" {
  type        = string
  description = "Name of the network"
}

variable "esxi_host_name" {
  type        = string
  description = "Name of the ESXi host"
}

variable "iso_datastore_name" {
  type        = string
  description = "The datastore name where the ISO file is located"
}

# VM Configuration
variable "vm_name" {
  type        = string
  description = "Name of the VM"
}

variable "vm_folder" {
  type        = string
  description = "VM folder path (optional)"
  default     = ""
}

variable "vm_cpu_count" {
  type        = number
  description = "Number of CPUs"
}

variable "vm_cpu_cores" {
  type        = number
  description = "Number of cores per socket"
}

variable "vm_memory_mb" {
  type        = number
  description = "Memory in MB"
}

variable "vm_disk_gb" {
  type        = number
  description = "Disk size in GB"
}

variable "guest_id" {
  type        = string
  description = "Guest OS ID"
  default     = "rhel8_64Guest"
}

# ISO Configuration
variable "guardium_iso_path" {
  type        = string
  description = "Path to the Guardium ISO file"
}

