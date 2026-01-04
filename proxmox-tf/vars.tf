variable "PM_API_URL" {
  description = "The URL of the Proxmox API."
  type        = string
}

variable "PM_API_TOKEN_ID" {
  description = "The ID of the Proxmox API token."
  type        = string
}

variable "PM_API_TOKEN_SECRET" {
  description = "The secret of the Proxmox API token."
  type        = string
  sensitive   = true
}

variable "PM_TLS_INSECURE" {
  description = "Whether to skip TLS certificate verification. Should be false in production."
  type        = bool
  default     = false
}

variable "ssh_public_key" {
  description = "The public SSH key to be added to the VMs for authentication."
  type        = string
}

variable "vm_user" {
  description = "The username for the cloud-init user."
  type        = string
  default     = "ubuntu"
}

variable "proxmox_host" {
  description = "The Proxmox node to deploy the VMs on."
  type        = string
  default     = "pve"
}

variable "template_name" {
  description = "The name of the VM template to clone."
  type        = string
  default     = "ubuntu-2404-k3s-template"
}

variable "pm_log_enable" {
  description = "Enable logging for the Proxmox provider."
  type        = bool
  default     = true
}

variable "pm_log_file" {
  description = "The path to the log file for the Proxmox provider."
  type        = string
  default     = "terraform-plugin-proxmox.log"
}

variable "k3s_nodes" {
  description = "The number of k3s nodes to create."
  type        = number
  default     = 3
}

variable "vm_cpu_cores" {
  description = "The number of CPU cores for each VM."
  type        = number
  default     = 1
}

variable "vm_cpu_sockets" {
  description = "The number of CPU sockets for each VM."
  type        = number
  default     = 1
}

variable "vm_memory" {
  description = "The amount of memory in MB for each VM."
  type        = number
  default     = 3072
}

variable "vm_disk_size" {
  description = "The size of the disk in GB for each VM."
  type        = string
  default     = "50G"
}

variable "k3s_node_ips" {
  description = "A list of IP addresses for the k3s nodes."
  type        = list(string)
  default     = ["192.168.68.223/24", "192.168.68.224/24", "192.168.68.225/24"]
}

variable "gateway_ip" {
  description = "The gateway IP address for the VMs."
  type        = string
  default     = "192.168.68.1"
}

variable "resource_pool_name" {
  description = "The name of the resource pool to create for the k3s cluster."
  type        = string
  default     = "k3s-cluster-pool"
}

variable "vm_password" {
  description = "The password for the cloud-init user. Only use this if you are not using SSH keys or for initial setup."
  type        = string
  sensitive   = true
  default     = ""
}