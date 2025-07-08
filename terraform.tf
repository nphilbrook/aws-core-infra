terraform {
  required_version = "~>1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.35"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~>0.53"
    }
  }
}
