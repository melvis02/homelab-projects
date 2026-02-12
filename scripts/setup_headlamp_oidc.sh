#!/bin/bash
set -e

# Prompt for OIDC details
echo "Headlamp OIDC Authentication Setup"
echo "----------------------------------"
echo "You will need a Google OAuth 2.0 Client ID and Secret."
echo "Redirect URI: https://headlamp.treympick.me/oidc-callback"
echo "Authorized JavaScript Origins: https://headlamp.treympick.me"
echo ""

# Load environment variables if available
if [ -f "env-vars.txt" ]; then
  source env-vars.txt
  echo "Loaded environment variables from env-vars.txt"
fi

read -p "Enter OIDC Issuer URL (e.g., https://accounts.google.com): " OIDC_ISSUER_URL
read -p "Enter OIDC Client ID: " OIDC_CLIENT_ID
read -s -p "Enter OIDC Client Secret: " OIDC_CLIENT_SECRET
echo ""

# Create Kubernetes Secret for Headlamp
echo "Creating/Updating Kubernetes Secret 'headlamp-oidc-values'..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: headlamp-oidc-values
  namespace: kube-system
stringData:
  values.yaml: |
    config:
      oidc:
        enabled: true
        clientID: "${OIDC_CLIENT_ID}"
        clientSecret: "${OIDC_CLIENT_SECRET}"
        issuerURL: "${OIDC_ISSUER_URL}"
        scopes: "openid profile email"
EOF

# Apply Terraform changes
echo "Applying Terraform changes to Talos control plane..."
cd proxmox-talos-tf
tofu init
tofu apply \
  -var="oidc_issuer_url=${OIDC_ISSUER_URL}" \
  -var="oidc_client_id=${OIDC_CLIENT_ID}"

echo "Setup complete! Headlamp should restart soon with OIDC enabled."
