locals {
  tags_labels = {
    "created-by"       = "terraform",
    "source-workspace" = var.TFC_WORKSPACE_SLUG
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = local.tags_labels
  }
}

provider "aws" {
  region = "us-west-2"
  alias  = "usw2"
  default_tags {
    tags = local.tags_labels
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "use1"
  default_tags {
    tags = local.tags_labels
  }
}

provider "tfe" {
  hostname = var.tfc_hostname
}
