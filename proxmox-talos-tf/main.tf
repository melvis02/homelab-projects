resource "proxmox_pool" "talos_cluster_pool" {
  poolid  = var.resource_pool_name
  comment = "Talos Cluster Pool"
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type      = "controlplane"
  machine_secrets   = talos_machine_secrets.this.machine_secrets
  kubernetes_version = "v1.32.0"
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type      = "worker"
  machine_secrets   = talos_machine_secrets.this.machine_secrets
  kubernetes_version = "v1.32.0"
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for ip in var.control_plane_ips : ip]
}

resource "talos_machine_configuration_apply" "controlplane" {
  count                       = length(var.control_plane_ips)
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = var.control_plane_ips[count.index]
  depends_on                  = [proxmox_vm_qemu.control_plane]
}

resource "talos_machine_configuration_apply" "worker" {
  count                       = 1
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = var.worker_ips[1]
  depends_on                  = [proxmox_vm_qemu.worker]
}

resource "talos_machine_configuration_apply" "gpu_worker" {
  count                       = 1
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = var.worker_ips[0]
  depends_on                  = [proxmox_vm_qemu.gpu_worker]
}

resource "talos_machine_bootstrap" "this" {
  depends_on           = [talos_machine_configuration_apply.controlplane]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.control_plane_ips[0]
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.control_plane_ips[0]
  depends_on           = [talos_machine_bootstrap.this]
}

resource "proxmox_vm_qemu" "control_plane" {
  count       = length(var.control_plane_ips)
  name        = "talos-cp-${count.index}"
  target_node = var.proxmox_host
  pool        = var.resource_pool_name
  
  # iso         = var.talos_iso
  
  agent       = 0 # Disabled to avoid waiting for QEMU agent
  
  cpu {
    cores   = var.vm_cpu_cores
    sockets = 1
    type    = "host"
  }
  
  memory = var.vm_memory
  
  scsihw = "virtio-scsi-single"
  
  disk {
    slot    = "scsi0"
    size    = var.vm_disk_size
    storage = "local-lvm"
    iothread = true
  }

  disk {
    slot = "ide2"
    type = "cdrom"
    iso  = var.talos_iso
  }

  
  network {
    id      = 0
    bridge  = "vmbr0"
    model   = "virtio"
    macaddr =var.control_plane_macs[count.index]
  }
  
  # Talos doesn't use cloud-init like Ubuntu
  os_type = "linux"
  boot    = "order=scsi0;ide2" # Boot from disk first, then CDROM (ISO) if empty? Or explicitly ISO first? 
  # Actually for installation we need to boot ISO.
  # Proxmox boot order string: "order=ide2;scsi0" -> IDE2 is usually the CDROM.
  # After install, Talos installs to disk.
  # Let's try order=scsi0;ide2 and rely on empty disk falling back to ISO, or explicitly set boot to ISO for first run.
  # A common pattern is to just leave it as implicit or set it to disk. 
  # If disk is empty, bios usually tries next device.
  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}

resource "proxmox_vm_qemu" "gpu_worker" {
  count       = 1
  name        = "talos-gpu-worker-0"
  target_node = var.proxmox_host
  pool        = var.resource_pool_name
  
  # iso         = var.talos_iso
  
  cpu {
    cores   = var.vm_cpu_cores
    sockets = 1
    type    = "host"
  }
  
  memory = var.vm_memory
  
  scsihw = "virtio-scsi-single"
  
  # Enable Q35 machine type for PCI passthrough
  machine = "q35"

  pci {
    id          = 0
    mapping_id  = "igpu"
    rombar      = true
    pcie        = true
    primary_gpu = true
  }

  disk {
    slot    = "scsi0"
    size    = var.vm_disk_size
    storage = "local-lvm"
    iothread = true
  }

  disk {
    slot = "ide2"
    type = "cdrom"
    iso  = var.talos_iso
  }
  
  network {
    id      = 0
    bridge  = "vmbr0"
    model   = "virtio"
    macaddr = var.worker_macs[0]
  }
  
  os_type = "linux"
  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}

resource "proxmox_vm_qemu" "worker" {
  count       = 1
  name        = "talos-worker-1"
  target_node = var.proxmox_host
  pool        = var.resource_pool_name
  
  # iso         = var.talos_iso
  
  cpu {
    cores   = var.vm_cpu_cores
    sockets = 1
    type    = "host"
  }
  
  memory = var.vm_memory
  
  scsihw = "virtio-scsi-single"
  
  disk {
    slot    = "scsi0"
    size    = var.vm_disk_size
    storage = "local-lvm"
    iothread = true
  }

  disk {
    slot = "ide2"
    type = "cdrom"
    iso  = var.talos_iso
  }
  
  network {
    id      = 0
    bridge  = "vmbr0"
    model   = "virtio"
    macaddr = var.worker_macs[1]
  }
  
  os_type = "linux"
  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}
