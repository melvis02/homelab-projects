output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "control_plane_ips" {
  value = var.control_plane_ips
}

output "worker_ips" {
  value = var.worker_ips
}

output "control_plane_macs" {
  value = proxmox_vm_qemu.control_plane[*].network[0].macaddr
}

output "worker_macs" {
  value = proxmox_vm_qemu.worker[*].network[0].macaddr
}
