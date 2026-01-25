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
  description = "Whether to skip TLS certificate verification."
  type        = bool
  default     = false
}

variable "proxmox_host" {
  description = "The Proxmox node to deploy the VMs on."
  type        = string
  default     = "pve"
}

variable "resource_pool_name" {
  description = "The name of the resource pool to create for the Talos cluster."
  type        = string
  default     = "talos-cluster-pool"
}

variable "talos_iso" {
  description = "The location of the Talos ISO image in Proxmox storage."
  type        = string
  default     = "local:iso/talos-v1.12.2-metal-amd64.iso"
}

variable "vm_cpu_cores" {
  description = "The number of CPU cores for each VM."
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "The amount of memory in MB for each VM."
  type        = number
  default     = 4096
}

variable "vm_disk_size" {
  description = "The size of the disk in GB for each VM."
  type        = string
  default     = "50G"
}

variable "control_plane_ips" {
  description = "List of IPs for control plane nodes."
  type        = list(string)
  default     = ["192.168.71.10"]
}

variable "worker_ips" {
  description = "List of IPs for worker nodes."
  type        = list(string)
  default     = ["192.168.71.11", "192.168.71.12"]
}

variable "subnet_cidr" {
  description = "The CIDR block for the nodes (e.g., /22)."
  type        = string
  default     = "/22"
}

variable "gateway_ip" {
  description = "The gateway IP address for the VMs."
  type        = string
  default     = "192.168.68.1"
}

variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "talos-homelab"
}

variable "cluster_endpoint" {
  description = "The endpoint for the Talos cluster (usually the VIP or first control plane IP)."
  type        = string
  default     = "https://192.168.71.10:6443"
}

variable "pm_log_enable" {
  description = "Enable logging for the Proxmox provider."
  type        = bool
  default     = false
}

variable "pm_log_file" {
  description = "The path to the log file for the Proxmox provider."
  type        = string
  default     = "terraform-plugin-proxmox.log"
}

variable "control_plane_macs" {
  description = "MAC addresses for control plane nodes (required for DHCP reservations)"
  type        = list(string)
  default     = ["bc:24:11:7b:dc:f9"] 
}

variable "worker_macs" {
  description = "MAC addresses for worker nodes (required for DHCP reservations)"
  type        = list(string)
  default     = ["bc:24:11:d4:c8:aa", "bc:24:11:40:e1:cb"]
}
