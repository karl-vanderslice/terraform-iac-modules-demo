terraform {
  required_version = ">= 1.3.4"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.27.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.38.0"
    }
  }
}

