terraform {
  cloud {
    organization = "philbrook"

    workspaces {
      name    = "aws-core-infra"
      project = "SB Vault Lab"
    }
  }
}
