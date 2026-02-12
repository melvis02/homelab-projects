# Homelab Maintenance Guide

This guide covers regular maintenance tasks for your Proxmox and Kubernetes homelab.

## Credentials & Secrets

### Rotating Secrets (SOPS + Age)
Your secrets are encrypted using Mozilla SOPS and Age. The private key is located at `age.agekey` in the root of the repository.

To edit an existing secret:
```bash
# Ensure environment is loaded (e.g., `direnv allow` or `source .envrc`)
sops infrastructure/path/to/secret.sops.yaml
```

To create a new secret:
```bash
# maintain the .sops.yaml rules
sops infrastructure/path/to/new-secret.sops.yaml
```

To rotate the Age key:
1. Generate a new key: `age-keygen -o new.agekey`
2. Update `.sops.yaml` with the new public key.
3. Re-encrypt all secrets:
   ```bash
   find . -name "*.sops.yaml" -exec sops --rotate --in-place --add-age <new_public_key> --rm-age <old_public_key> {} \;
   ```

## Updates

### Proxmox VE
1. SSH into the Proxmox host.
2. Run standard Debian updates:
   ```bash
   apt update
   apt dist-upgrade
   ```
3. Reboot if a kernel update was installed.

### Talos Kubernetes Nodes
Talos is immutable. Updates are applied via API.

1. **Backup**: Ensure you have a recent etcd backup (automatic snapshorts are good, but verify).
2. **Upgrade Control Plane**:
   ```bash
   talosctl upgrade --nodes <cp-node-ip> --image ghcr.io/siderolabs/installer:<new-version> --preserve
   ```
   Wait for the node to reboot and rejoin the cluster.
3. **Upgrade Workers**:
   ```bash
   talosctl upgrade --nodes <worker-node-ip> --image ghcr.io/siderolabs/installer:<new-version> --preserve
   ```

### Kubernetes Workloads (Flux)
Most workloads are managed by Flux.

1. **Helm Charts**:
   - Check `repository.yaml` or `release.yaml` files for version pins.
   - Update the `version` field to the desired version.
   - Commit and push. Flux will apply the update.
   
2. **Flux Itself**:
   - Flux manages itself via the `flux-system` components.
   - Upgrade the Flux CLI locally: `brew upgrade fluxcd/tap/flux`
   - Run bootstrap again to update the cluster components:
     ```bash
     flux bootstrap github --owner=<user> --repository=<repo> --path=clusters/talos-homelab
     ```

## Backup & Restore

### Kubernetes Resources
Ensure all your manifests are committed to git. This is your primary restoration source.

### Persistent Data
(Add details if Velero or other backup solutions are implemented)
- Currently, standard GitOps practices cover configuration.
- For PVCs, consider setting up VolumeSnapshots if your storage provider supports it.
