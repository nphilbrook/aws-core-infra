import {
  to = tfe_variable_set.aws_variable_set
  id = "varset-pDJjiY2SFqagYQ3p"
}
# Runs with this variable set will be automatically authenticated
# to AWS with the permissions set in the AWS policy.
#
resource "tfe_variable_set" "aws_variable_set" {
  name   = var.tfc_variable_set_name
  global = true
}

import {
  to = tfe_variable.enable_aws_provider_auth
  id = "philbrook/varset-pDJjiY2SFqagYQ3p/var-ougC3NRWvytGH1cU"
}
# The following variables must be set to allow runs
# to authenticate to AWS.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "enable_aws_provider_auth" {
  variable_set_id = tfe_variable_set.aws_variable_set.id

  key      = "TFC_AWS_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for AWS."
}

import {
  to = tfe_variable.tfc_aws_role_arn
  id = "philbrook/varset-pDJjiY2SFqagYQ3p/var-gA8qWC2xgnKzxd5X"
}
resource "tfe_variable" "tfc_aws_role_arn" {
  variable_set_id = tfe_variable_set.aws_variable_set.id

  key      = "TFC_AWS_RUN_ROLE_ARN"
  value    = aws_iam_role.tfc_role.arn
  category = "env"

  description = "The AWS role arn runs will use to authenticate."
}

# The following variables are optional; uncomment the ones you need!

# resource "tfe_variable" "tfc_aws_audience" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_AWS_WORKLOAD_IDENTITY_AUDIENCE"
#   value    = var.tfc_aws_audience
#   category = "env"

#   description = "The value to use as the audience claim in run identity tokens"
# }

# The following is an example of the naming format used to define variables for
# additional configurations. Additional required configuration values must also
# be supplied in this same format, as well as any desired optional configuration
# values.
#
# Additional configurations can be used to uniquely authenticate multiple aliases
# of the same provider in a workspace, with different roles/permissions in different
# accounts or regions.
#
# See https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/specifying-multiple-configurations
# for more details on specifying multiple configurations.
#
# See https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration#specifying-multiple-configurations
# for specific requirements and details for the AWS provider.

# resource "tfe_variable" "enable_aws_provider_auth_other_config" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_AWS_PROVIDER_AUTH_other_config"
#   value    = "true"
#   category = "env"

#   description = "Enable the Workload Identity integration for AWS for an additional configuration named other_config."
# }
