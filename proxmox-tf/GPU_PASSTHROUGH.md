# Proxmox Intel iGPU Passthrough Guide

This guide documents the configuration required to pass through an Intel UHD 620 (or similar) iGPU to an Ubuntu guest on Proxmox using Terraform.

## 1. Proxmox Host Configuration (Prerequisites)
Before using Terraform, the Proxmox host must be configured to allow IOMMU and prevent the host from claiming the GPU.

*   **BIOS/UEFI**: Enable `VT-d` / `IOMMU`.
*   **Kernel Command Line** (`/etc/default/grub`):
    *   Add: `intel_iommu=on iommu=pt`
    *   Run `update-grub` and reboot.
*   **Modules** (`/etc/modules`):
    *   Add: `vfio`, `vfio_iommu_type1`, `vfio_pci`.
*   **Blacklist** (`/etc/modprobe.d/blacklist.conf`):
    *   Add: `blacklist i915` (prevents host from using the GPU).
*   **Resource Mapping**:
    *   Create a PCI Resource Mapping in Proxmox UI (`Datacenter` -> `Resource Mappings`).
    *   Name: `igpu` (or match `main.tf`).
    *   ID: `0000:00:02.0` (Use `lspci` to verify).

## 2. Terraform Configuration (`main.tf`)
Use the `pci` block (or `hostpci` if preferred, but `pci` is used here) with the Resource Mapping.

> **Note**: The `args` parameter (`x-igd-opregion=on`) technically fixes some issues but requires root. We use `primary_gpu = true` (which enables `x-vga`) as a supported alternative.

```hcl
  pci {
    id          = 0
    mapping_id  = "igpu"   # Must match Proxmox Resource Mapping name
    rombar      = true
    pcie        = true     # Required for 'q35' machine type
    primary_gpu = true     # critical: sets x-vga=on, helps guest init
  }
```

**Permission Requirements:**
*   The Terraform user/token must have `Mapping.Use` permission on `/mapping/pci/igpu`.

## 3. VM Guest Configuration (Ubuntu)
**CRITICAL:** Cloud images and minimal installs often lack the `extra` kernel modules properly.

If `ls -l /dev/dri` is missing but `lspci` shows the device:
1.  **Install Extras**:
    ```bash
    sudo apt update
    sudo apt install -y linux-modules-extra-$(uname -r)
    ```
2.  **Load Driver**:
    ```bash
    sudo modprobe i915
    ```
3.  **Verify**:
    ```bash
    ls -l /dev/dri
    # Should show card0 and renderD128
    ```
