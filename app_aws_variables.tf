# COMMON TO ALL WORKSPACES

# Runs with this variable set will be automatically authenticated
# to AWS with vault-backed dynamic credentials
resource "tfe_variable_set" "common_vault_backed_dynamic_aws_variable_set" {
  name   = "Common Vault-Backed Dynamic AWS Credentials Variables"
  global = false
}

resource "tfe_variable" "enable_vault_provider_auth" {
  variable_set_id = tfe_variable_set.common_vault_backed_dynamic_aws_variable_set.id

  key      = "TFC_VAULT_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable dynmaic Vault provider auth"
}

resource "tfe_variable" "vault_address" {
  variable_set_id = tfe_variable_set.common_vault_backed_dynamic_aws_variable_set.id

  key      = "TFC_VAULT_ADDR"
  value    = "https://vault-cluster-private-vault-e9bf486c.f4702644.z1.hashicorp.cloud:8200/"
  category = "env"

  description = "Vault address"
}

resource "tfe_variable" "vault_namespace" {
  variable_set_id = tfe_variable_set.common_vault_backed_dynamic_aws_variable_set.id

  key = "TFC_VAULT_NAMESPACE"
  # TODO: move this once namespaces are designed and deployed
  value    = "admin"
  category = "env"

  description = "Vault namespace"
}

resource "tfe_variable" "enable_vault_backed_aws_provider_auth" {
  variable_set_id = tfe_variable_set.common_vault_backed_dynamic_aws_variable_set.id

  key      = "TFC_VAULT_BACKED_AWS_AUTH"
  value    = "true"
  category = "env"

  description = "Enable dynmaic AWS provider auth backed by Vault"
}

resource "tfe_variable" "aws_auth_type" {
  variable_set_id = tfe_variable_set.common_vault_backed_dynamic_aws_variable_set.id

  key      = "TFC_VAULT_BACKED_AWS_AUTH_TYPE"
  value    = "assumed_role"
  category = "env"

  description = "Use assumed_role auth type"
}
# END COMMON

# APP/WORKSPACE SPECIFIC
resource "tfe_variable_set" "probable_pancake_vault_backed_dynamic_aws_variable_set" {
  name   = "Probable Pancake Vault-Backed Dynamic AWS Credentials Variables"
  global = false
}

resource "tfe_variable" "vault_run_role" {
  variable_set_id = tfe_variable_set.probable_pancake_vault_backed_dynamic_aws_variable_set.id

  key      = "TFC_VAULT_RUN_ROLE"
  value    = "hcp-tf-probable-pancake"
  category = "env"

  description = "Vault JWT role for this workspace"
}

resource "tfe_variable" "vault_aws_run_role" {
  variable_set_id = tfe_variable_set.probable_pancake_vault_backed_dynamic_aws_variable_set.id

  key      = "TFC_VAULT_BACKED_AWS_RUN_VAULT_ROLE"
  value    = "probable-pancake-tf"
  category = "env"

  description = "Vault AWS role for this workspace"
}

resource "tfe_variable" "vault_aws_run_role_arn" {
  variable_set_id = tfe_variable_set.probable_pancake_vault_backed_dynamic_aws_variable_set.id

  key      = "TFC_VAULT_BACKED_AWS_RUN_ROLE_ARN"
  value    = "arn:aws:iam::517068637116:role/dyn-ec2-access"
  category = "env"

  description = "Vault AWS role for this workspace"
}
# END APP/WORKSPACE SPECIFIC

# ASSOCIATE TO WORKSPACE
locals {
  probbale_pancake_wsid = "ws-J6PNGjVXWP19mEtu"
}

resource "tfe_workspace_variable_set" "common" {
  variable_set_id = tfe_variable_set.common_vault_backed_dynamic_aws_variable_set.id
  workspace_id    = local.probbale_pancake_wsid
}

resource "tfe_workspace_variable_set" "probable_pancake" {
  variable_set_id = tfe_variable_set.probable_pancake_vault_backed_dynamic_aws_variable_set.id
  workspace_id    = local.probbale_pancake_wsid
}
# END ASSOCIATE TO WORKSPACE
