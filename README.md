# homelab-projects

**Homelab code, Terraform, and scripts** 🔧

## Current status ✅
This repository currently contains Terraform HCL used to create virtual machines in Proxmox (see the `proxmox-tf/` directory). Those VMs are intended to be used as Kubernetes nodes.

## Contents
- `proxmox-tf/` — Terraform configuration for provisioning VMs in Proxmox (nodes for Kubernetes).

### `proxmox-tf/` details 🔍
A brief description of notable files in `proxmox-tf/`:

- `main.tf` — Primary Terraform configuration that defines VM resources and modules.
- `vars.tf` — Variable definitions and defaults used by the configuration.
- `terraform.tfvars` — (local) variable values; this file is typically **not** committed with secrets.
- `terraform.tfvars.example` — Example/template for `terraform.tfvars` (see below).
- `terraform.tfstate` / `terraform.tfstate.backup` — Terraform state files (may contain sensitive data; avoid committing them).

You can copy `terraform.tfvars.example` -> `terraform.tfvars` and fill in provider credentials and values.

## Future plans 💡
This repo will grow to include various scripts, code, Terraform configurations, and tooling for managing and automating my homelab.

## Usage (short)
Change into the `proxmox-tf/` directory and use Terraform as usual:

```bash
cd proxmox-tf
terraform init
terraform plan
terraform apply
```

> **Note:** Ensure Proxmox provider credentials and any sensitive values are provided via secure means (environment variables or a local `terraform.tfvars` that is not committed). `terraform.tfstate` can contain sensitive data — avoid committing secrets.

---

If you'd like, I can also add a short example, contributor notes, or expand the usage section. 
