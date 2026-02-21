terraform {
  required_version = "~>1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~>0.53"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~>0.111"
    }
  }
}
