locals {
  hvn_account_id = "734224019710"
}

resource "aws_ec2_transit_gateway" "example" {
  tags = {
    Name = "example-tgw"
  }
}

resource "aws_ram_resource_share" "example" {
  name                      = "example-resource-share"
  allow_external_principals = true
}

resource "aws_ram_principal_association" "example" {
  resource_share_arn = aws_ram_resource_share.example.arn
  principal          = local.hvn_account_id
}

resource "aws_ram_resource_association" "example" {
  resource_share_arn = aws_ram_resource_share.example.arn
  resource_arn       = aws_ec2_transit_gateway.example.arn
}


resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "example" {
  transit_gateway_attachment_id = "TBD" # hcp_aws_transit_gateway_attachment.example.provider_transit_gateway_attachment_id
}
