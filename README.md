# Homelab Projects 🔧

Infrastructure as Code (IaC) repository for my Proxmox Homelab and Kubernetes cluster managed by **Talos Linux** and **FluxCD**.

## Overview
This project uses **OpenTofu** (via Terraform) to provision Virtual Machines on Proxmox and **Talos Linux** to manage the Kubernetes cluster. The cluster is managed using **GitOps** principles via **FluxCD**, hosting services like **Channels DVR** with hardware transcoding support.

### Architecture
*   **Infrastructure**: [OpenTofu](proxmox-talos-tf/) provisioning 3 VMs (1 Control Plane, 2 Workers) running Talos Linux.
*   **GitOps**: [FluxCD](clusters/talos-homelab/) manages cluster state by synchronizing manifests from this repository.
*   **Hardware Setup**: Intel iGPU (UHD 620) passthrough via custom Talos Image Factory builds.
*   **Ingress & Routing**: [Cloudflare Tunnel](infrastructure/cloudflare-tunnel/) for secure external exposure, [Traefik](infrastructure/traefik/) for internal routing.
*   **Services**:
    *   **Networking**: MetalLB + Traefik.
    *   **Security**: Cert-Manager + Cloudflare Tunnels.
    *   **Apps**: Channels DVR, Pi-hole, Fundfetti.

---

## 🚀 Getting Started

### Prerequisites
*   Proxmox VE 8.x
*   [OpenTofu](https://opentofu.org/)
*   [Talosctl](https://www.talos.dev/latest/introduction/getting-started/#installing-talosctl)
*   [Flux CLI](https://fluxcd.io/flux/installation/)
*   Configured Proxmox API Token.

### 1. Provision Infrastructure (OpenTofu)
Navigate to the `proxmox-talos-tf` directory and apply the configuration.

```bash
cd proxmox-talos-tf
tofu init
tofu apply
```

> **Note**: This provisions bare Talos nodes. You will need a custom Talos image with Intel iGPU drivers. See [docs/gpu-passthrough.md](docs/gpu-passthrough.md).

### 2. Bootstrap Flux CD
Once the cluster is initialized, bootstrap Flux to sync the repository.

```bash
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=homelab-projects \
  --branch=main \
  --path=./clusters/talos-homelab \
  --personal
```

### 3. Configure Cloudflare Tunnel
The tunnel secret is managed manually (not in Git). Create the secret in the `cloudflare-tunnel` namespace:

```bash
kubectl create secret -n cloudflare-tunnel generic cloudflare-tunnel-token --from-literal=token=YOUR_TOKEN
```

---

## 📺 Channels DVR & GPU

The cluster hosts **Channels DVR** with hardware transcoding enabled via Intel iGPU passthrough.

### Access Methods
1.  **Web UI (HTTPS)**: `https://dvr.treympick.me` (Routed via Cloudflare Tunnel -> Traefik).
2.  **Local Access (Port Forward)**: If the vanity domain is not yet active or for initial setup:
    ```bash
    kubectl port-forward svc/channels-dvr 8089:8089 -n channels-dvr
    ```
3.  **Remote Apps**: Standard Cloudflare Tunnel routing.

### GPU Passthrough
The Talos nodes run a custom image generated via [Talos Image Factory](https://factory.talos.dev/) including:
- `i915-ucode`
- `intel-ucode`
- `nonfree-kmod-intel-gvt-g` (if using GVT-g)

See [docs/gpu-passthrough.md](docs/gpu-passthrough.md) for the specific image schematic and configuration.

---

## Directory Structure
*   `proxmox-talos-tf/`: OpenTofu code for Talos VMs.
*   `infrastructure/`: Core cluster services (MetalLB, Traefik, Cert-Manager, Cloudflare-Tunnel).
*   `apps/`: Application manifests (Channels DVR, Pi-hole, Fundfetti).
*   `clusters/talos-homelab/`: Flux configuration for the home cluster.
*   `docs/`: Detailed hardware and setup guides.
    *   [gpu-passthrough.md](docs/gpu-passthrough.md)
    *   [talos-guide.md](docs/talos-guide.md)

---

## 🚀 Deploying New Applications

This cluster follows a GitOps workflow using **FluxCD**. To deploy a new application:

### 1. Create Application Manifests
Create a new directory in `apps/` for your application and include your Kubernetes manifests (Deployment, Service, Ingress, etc.).

Example: `apps/my-new-app/`

### 2. Add to Kustomization
Add the new directory to the `resources` list in [apps/kustomization.yaml](file:///Users/treympick/Projects/homelab-projects/apps/kustomization.yaml):

```yaml
resources:
  - fundfetti
  - pi-hole
  - channels-dvr
  - my-new-app # Add this line
```

### 3. Commit and Push
Once you push your changes to GitHub, Flux will automatically detect the changes and synchronize them to the cluster.

```bash
git add .
git commit -m "feat: deploy my-new-app"
git push origin main
```

### 4. Verify Sync
You can monitor the sync progress using the Flux CLI:

```bash
flux get kustomizations --watch
```
