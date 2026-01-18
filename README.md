# Homelab Projects 🔧

Infrastructure as Code (IaC) repository for my Proxmox Homelab and Kubernetes cluster.

## Overview
This project uses **Terraform** (via OpenTofu) to provision Virtual Machines on Proxmox and **Ansible** to configure them as a K3s Kubernetes cluster. It hosts services like **Channels DVR** with hardware transcoding support.

### Components
*   **Infrastructure**: [Terraform/OpenTofu](proxmox-tf/) provisioning 3 VMs (1 Control Plane, 2 Workers).
*   **Configuration**: [Ansible](deploy.yml) playbook using the official `k3s-ansible` role.
*   **Hardware Setup**: [GPU Passthrough](docs/gpu-passthrough.md) handling for Intel iGPU (UHD 620).
*   **Kubernetes Services**:
    *   **Networking**: MetalLB (LoadBalancer) + Traefik (Ingress) + Cert-Manager (Let's Encrypt).
    *   **Apps**: Channels DVR.

---

## 🚀 Getting Started

### Prerequisites
*   Proxmox VE 8.x
*   [OpenTofu](https://opentofu.org/) (Terraform fork)
*   [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
*   `sshpass` (optional, for Ansible password auth if needed)
*   Configured Proxmox API Token.

### 1. Provision Infrastructure (Terraform)
Navigate to the Terraform directory and apply the configuration.

```bash
cd proxmox-tf

# Initialize and Apply
tofu init
tofu apply
```

> **Note**: You must provide your Proxmox credentials. Create a `terraform.tfvars` file (see `terraform.tfvars.example`) or use environment variables (`TF_VAR_PM_API_TOKEN_ID`, etc.).

### 2. Generate Ansible Inventory
We use a helper script to convert Terraform outputs into an Ansible-compatible inventory.

```bash
# Inside proxmox-tf/
./generate_inventory.sh
```
This creates `../inventory.yml` in the project root.

### 3. Configure Cluster (Ansible)
Run the master playbook to install K3s, configure networking, and deploy applications.

```bash
cd ..
ansible-playbook deploy.yml
```

**What `deploy.yml` does:**
1.  **Bootstrap K3s**: Uses `k3s-ansible` submodule to install master/agent nodes.
2.  **Dependencies**: Installs `MetalLB` and `Cert-Manager` CRDs.
3.  **GPU Setup**: Labels the GPU node so the Intel Device Plugin works.
4.  **Manifests**: Applies local manifests from `k8s/` (Channels DVR, Ingress, etc.).

---

## 📺 Channels DVR & GPU

The cluster hosts **Channels DVR** with hardware transcoding enabled via Intel iGPU passthrough on `k3s-gpu-node`.

### Access Methods
1.  **Web UI (HTTPS)**: `https://dvr.treympick.me`
    *   Routed via Traefik Ingress (Port 443).
    *   Secured by Let's Encrypt.
2.  **Remote Apps**: `PublicIP:8089` -> `192.168.71.101:8089`
    *   The DVR Service has a dedicated LoadBalancer IP (`.101`) for direct port 8089 access.
    *   **Router Config**: Forward WAN:8089 to LAN:192.168.71.101:8089.

### GPU Passthrough
The `proxmox-vm-qemu` resource is configured with `hostpci` mapping for the Intel iGPU.
*   See [docs/gpu-passthrough.md](docs/gpu-passthrough.md) for Host/Guest configuration details.

---

## Directory Structure
*   `proxmox-tf/`: Terraform HCL code.
*   `k3s-ansible/`: Git submodule of the official [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible) repo.
*   `k8s/`: Kubernetes manifests (Deployments, PVCs, Services).
*   `deploy.yml`: Master Ansible playbook.
*   `ansible.cfg`: Configures Ansible to find roles in the submodule.
