locals {
  hvn_account_id = "734224019710"
}

# HUB?!
resource "aws_ec2_transit_gateway" "e2" {
  # implied e2 provider
  auto_accept_shared_attachments = "enable"
  tags = {
    Name = "tgw-e2"
  }
}

# resource "aws_ram_resource_share" "example" {
#   name                      = "example-resource-share"
#   allow_external_principals = true
# }

# resource "aws_ram_principal_association" "example" {
#   resource_share_arn = aws_ram_resource_share.example.arn
#   principal          = local.hvn_account_id
# }

# resource "aws_ram_resource_association" "example" {
#   resource_share_arn = aws_ram_resource_share.example.arn
#   resource_arn       = aws_ec2_transit_gateway.e2.arn
# }

# resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "example" {
#   transit_gateway_attachment_id = "TBD" # hcp_aws_transit_gateway_attachment.example.provider_transit_gateway_attachment_id
# }

resource "aws_ec2_transit_gateway_vpc_attachment" "e2" {
  # implied e2 provider
  subnet_ids         = [aws_subnet.e2.id]
  transit_gateway_id = aws_ec2_transit_gateway.e2.id
  vpc_id             = aws_vpc.e2.id
}


resource "aws_ec2_transit_gateway" "e1" {
  provider                       = aws.use1
  auto_accept_shared_attachments = "enable"
  tags = {
    Name = "tgw-e1"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "e1" {
  provider           = aws.use1
  subnet_ids         = [aws_subnet.e1.id]
  transit_gateway_id = aws_ec2_transit_gateway.e1.id
  vpc_id             = aws_vpc.e1.id
}

#### E2 / E1 PEERING
resource "aws_ec2_transit_gateway_peering_attachment" "example" {
  peer_region             = "us-east-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.e1.id
  transit_gateway_id      = aws_ec2_transit_gateway.e2.id

  tags = {
    Name = "E2 / E1 TGW Peering Requestor"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "e2_e1_accepnt" {
  provider                      = aws.use1
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.example.id

  tags = {
    Name = "E2 / E1 TGW Peering Acceptor"
  }
}
#### END E2 / E1 PEERING


# Since I used the default VPC here...
data "aws_vpc" "default_w2" {
  provider = aws.usw2
  default  = true
}

data "aws_subnets" "w2" {
  provider = aws.usw2
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_w2.id]
  }
}

resource "aws_ec2_transit_gateway" "w2" {
  provider                       = aws.usw2
  auto_accept_shared_attachments = "enable"
  tags = {
    Name = "tgw-w2"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "w2" {
  provider           = aws.usw2
  subnet_ids         = [data.aws_subnets.w2.ids[0]]
  transit_gateway_id = aws_ec2_transit_gateway.w2.id
  vpc_id             = data.aws_vpc.default_w2.id
}
