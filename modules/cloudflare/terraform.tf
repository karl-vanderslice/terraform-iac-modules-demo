# Shared Terraform (cli tool) configuration

terraform {
  required_version = ">= 1.3.4"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.27.0"
    }
  }
}