data "aws_caller_identity" "current" {}

# My bastion based
data "hcp_packer_artifact" "bastion" {
  bucket_name  = "bastion-rhel"
  channel_name = "dev"
  platform     = "aws"
  region       = "us-west-2"
}
