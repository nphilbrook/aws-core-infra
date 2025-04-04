terraform {
  cloud {
    organization = "philbrook"

    workspaces {
      name    = "tfe-scratch"
      project = "Default Project"
    }
  }
}
