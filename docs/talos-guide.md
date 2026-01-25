# Talosctl Cheat Sheet for Kubectl Users 🛠️

Since Talos Linux has **no SSH** and a **read-only filesystem**, `talosctl` is your "SSH replacement." It talks directly to the Talos API on each node.

## 1. The Basics
Always ensure your `TALOSCONFIG` is set or specify it with `--talosconfig`. By default, `talosctl` looks for a config in `~/.talos/config`. 

In this repository, your config is located in the terraform directory:

```bash
# Set an alias or environment variable for ease of use
export TALOSCONFIG=$(pwd)/proxmox-talos-tf/talosconfig

# Or use the flag explicitly
talosctl -n <node-ip> health --talosconfig ./proxmox-talos-tf/talosconfig

# Real-time dashboard (Must see!)
talosctl -n <node-ip> dashboard --talosconfig ./proxmox-talos-tf/talosconfig
```

## 2. "I need to see what's happening" (Logs & Info)
Instead of `journalctl`, use:

```bash
# View kernel logs (dmesg)
talosctl -n <node-ip> dmesg

# View service logs (e.g., kubelet, containerd)
talosctl -n <node-ip> logs kubelet
```

## 3. "Where are my containers?" (CRI level)
If `kubectl` is failing, check the container runtime directly:

```bash
# List all containers on a node
talosctl -n <node-ip> containers

# See processes on the node
talosctl -n <node-ip> ps
```

## 4. Hardware & Networking
```bash
# Check loaded kernel modules (e.g., for GPU)
talosctl -n <node-ip> get modules

# Check network interfaces and IPs
talosctl -n <node-ip> get links
talosctl -n <node-ip> get addresses
```

## 5. Maintenance
```bash
# Safe Reboot
talosctl -n <node-ip> reboot

# View the machine configuration (the source of truth)
talosctl -n <node-ip> get mc
```

## 6. Philosophy: Talos vs. K3s
| Action | K3s (Ubuntu) | Talos |
| :--- | :--- | :--- |
| **Login** | `ssh ubuntu@node` | `talosctl -n node dashboard` |
| **Check Logs** | `journalctl -u k3s` | `talosctl -n node logs kubelet` |
| **Reboot** | `sudo reboot` | `talosctl -n node reboot` |
| **Edit Config** | `vim /etc/rancher/k3s/...` | Edit GitOps -> Flux syncs to Talos API |
| **Kernel Modules** | `modprobe i915` | Defined in MachineConfig / Image Factory |
