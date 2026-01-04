terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  # url is the hostname (FQDN if you have one) for the proxmox host
  pm_api_url = var.PM_API_URL
  # api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = var.PM_API_TOKEN_ID
  # api token secret is the long alphanumeric string you generated when you created the api token
  pm_api_token_secret = var.PM_API_TOKEN_SECRET
  # leave tls_insecure set to true until we have public certs set up
  pm_tls_insecure = var.PM_TLS_INSECURE

  pm_log_enable = var.pm_log_enable
  pm_log_file   = var.pm_log_file
}

resource "proxmox_pool" "k3s-cluster-pool" {
  poolid  = var.resource_pool_name
  comment = "K3s Cluster Pool"
}

resource "proxmox_vm_qemu" "k3s_node" {
  for_each = toset(slice(var.k3s_node_ips, 0, var.k3s_nodes))

  name        = "k3s-node-${index(var.k3s_node_ips, each.value) + 1}"
  target_node = var.proxmox_host    # Proxmox node name
  clone       = var.template_name   # Template VM name

  # The destination resource pool for the new VM
  pool = var.resource_pool_name

  agent = 1

  cpu {
    cores   = var.vm_cpu_cores
    sockets = var.vm_cpu_sockets
  }

  memory = var.vm_memory

  scsihw = "virtio-scsi-single"
  boot   = "order=scsi0"

  serial {
    id   = 0
    type = "socket"
  }

  disk {
    slot    = "scsi0"
    size    = var.vm_disk_size
    storage = "local-lvm"
    iothread = true
  }

  disk {
    slot    = "scsi1"
    type    = "cloudinit"
    storage = "local-lvm"
  }

  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }

  os_type = "cloud-init"
  ipconfig0 = "ip=${each.value},gw=${var.gateway_ip}"
  sshkeys   = var.ssh_public_key
  ciuser    = var.vm_user
  # It is recommended to use SSH keys for authentication instead of passwords.
  # However, if you need to set a password, you can do so here.
  # The password should be set as an environment variable for security:
  # export TF_VAR_vm_password="your_password"
  cipassword = var.vm_password != "" ? var.vm_password : null
  # Ignore changes to the network
  ## MAC address is generated on every apply, causing
  ## TF to think this needs to be rebuilt on every apply
  lifecycle {
     ignore_changes = [
       network
     ]
  }

}

output "k3s_node_ips" {
  value = [for node in values(proxmox_vm_qemu.k3s_node) : node.default_ipv4_address]
}

