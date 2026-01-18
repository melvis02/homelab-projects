#!/bin/bash
set -e

# Navigate to script directory
cd "$(dirname "$0")"

echo "Generating Ansible Inventory from Terraform..."
tofu output -raw ansible_inventory > ../inventory.yml

echo "Inventory saved to ../inventory.yml"
cat ../inventory.yml
