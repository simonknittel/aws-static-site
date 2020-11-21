terraform {
  required_version = ">= 0.13"

  backend "remote" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.16.0"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "2.12.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.0.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Certificates for Cloudfront must be stored in us-east-1
provider "aws" {
  alias = "for_certificates"
  region = "us-east-1"
}

locals {
  full_domain = "${var.subdomain}.${var.cloudflare_zone_name}"
}
