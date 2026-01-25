terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.10.0"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.PM_API_URL
  pm_api_token_id = var.PM_API_TOKEN_ID
  pm_api_token_secret = var.PM_API_TOKEN_SECRET
  pm_tls_insecure = var.PM_TLS_INSECURE
  pm_log_enable = var.pm_log_enable
  pm_log_file   = var.pm_log_file
}

provider "talos" {}
