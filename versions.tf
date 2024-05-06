terraform {
  required_version = "~>1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.35"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~>0.53"
    }
  }
}

locals {
  tags_labels = { "created-by" = "terraform" }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = local.tags_labels
  }
}

provider "tfe" {
  hostname = var.tfc_hostname
}
