# Proxmox Intel iGPU Passthrough Guide (Talos Linux)

This guide documents the configuration required to pass through an Intel UHD 620 (or similar) iGPU to a **Talos Linux** guest on Proxmox.

## 1. Proxmox Host Configuration
The Proxmox host must be configured to allow IOMMU and prevent the host from claiming the GPU.

*   **BIOS/UEFI**: Enable `VT-d` / `IOMMU`.
*   **Kernel Command Line** (`/etc/default/grub`):
    *   Add: `intel_iommu=on iommu=pt`
    *   Run `update-grub` and reboot.
*   **Resource Mapping**:
    *   Create a PCI Resource Mapping in Proxmox UI (`Datacenter` -> `Resource Mappings`).
    *   Name: `igpu`.
    *   ID: `0000:00:02.0` (Verify with `lspci`).

## 2. Talos Image Factory (Custom Image)
Talos requires a custom image containing the `i915` firmware and kernel modules.

1.  Visit [Talos Image Factory](https://factory.talos.dev/).
2.  Select your Hardware (e.g., `amd64`).
3.  Select Talos version.
4.  Add the following extensions:
    - `siderolabs/i915-ucode`
    - `siderolabs/intel-ucode`
    - `siderolabs/intel-gpu-firmware` (if available/needed for your generation)
5.  Download the **ISO** or **Maintenance** image URL and use it in your OpenTofu configuration.

## 3. OpenTofu Configuration (`main.tf`)
Configure the `pci` block to use the mapping. Ensure `machine = "q35"`.

```hcl
  pci {
    id          = 0
    mapping_id  = "igpu"
    rombar      = true
    pcie        = true
    primary_gpu = true
  }
```

## 4. Talos Configuration (Machine Config)
To ensure the `i915` driver loads and the devices are accessible in Kubernetes:

### Kernel Modules
Add `i915` to the extra kernel modules in your machine config:

```yaml
machine:
  kernel:
    modules:
      - name: i915
```

### Device Plugins
Install the [Intel Device Plugin for Kubernetes](https://github.com/intel/intel-device-plugins-for-kubernetes) via Flux to expose the GPU to pods.

```bash
# Verify on a node
talosctl -n <node-ip> ssh -- kmsg | grep i915
```

## 5. Verifying Passthrough in Pods
Check for `/dev/dri/renderD128` inside the container:

```bash
kubectl exec -it <pod-name> -- ls -l /dev/dri
# Should show card0 and renderD128
```
