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

## Deploying Kubernetes 🚀
I provisioned the VMs with the Terraform in `proxmox-tf/` and then deployed a Kubernetes cluster using the k3s-ansible playbook: https://github.com/k3s-io/k3s-ansible. Below are concise reproduction notes so you don't lose track:

1. Provision VMs with the `proxmox-tf/` configuration (see Usage above).
2. Ensure you can SSH into the VMs (update inventory with IPs/hostnames and SSH user).
3. Create or adapt an Ansible inventory (e.g., `inventory/hosts.ini`) and set any group vars (SSH user, k3s version, extra flags).
4. Run the upstream playbook following its README, for example:

```bash
ansible-playbook -i inventory/hosts.ini site.yml -K
```

> Tip: Keep any per-environment variables (tokens, secrets) out of the repo and use Ansible vault or environment variables.

This documents how the current cluster was created; adapt inventory and variables to your environment and the k3s-ansible README for full options.

---

If you'd like, I can also add a short example inventory, or add a note about the k3s version and any extra flags you used. 
