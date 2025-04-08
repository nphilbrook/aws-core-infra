locals {
  hvn_account_id = "734224019710"
}

# HUB?! NO. No hub.
resource "aws_ec2_transit_gateway" "e2" {
  # implied e2 provider
  auto_accept_shared_attachments = "enable"
  tags = {
    Name = "tgw-e2"
  }
}

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

resource "aws_ec2_transit_gateway_vpc_attachment" "e1_2" {
  provider           = aws.use1
  subnet_ids         = [aws_subnet.e1_2.id]
  transit_gateway_id = aws_ec2_transit_gateway.e1.id
  vpc_id             = aws_vpc.e1_2.id
}

# intra E1 routing targeting the TGW in E1
resource "aws_route" "e1_4_to_5_route" {
  provider               = aws.use1
  route_table_id         = aws_vpc.e1.main_route_table_id
  destination_cidr_block = aws_vpc.e1_2.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.e1.id
}

resource "aws_route" "e1_5_to_4_route" {
  provider               = aws.use1
  route_table_id         = aws_vpc.e1_2.main_route_table_id
  destination_cidr_block = aws_vpc.e1.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.e1.id
}


#### E2 / E1 PEERING
resource "aws_ec2_transit_gateway_peering_attachment" "e2_e1_peering" {
  peer_region             = "us-east-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.e1.id
  transit_gateway_id      = aws_ec2_transit_gateway.e2.id

  tags = {
    Name = "E2 / E1 TGW Peering Requestor"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "e2_e1_acceptor" {
  provider                      = aws.use1
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.e2_e1_peering.id

  tags = {
    Name = "E2 / E1 TGW Peering Acceptor"
  }
}

# E2 -> E1 *transit* route
resource "aws_ec2_transit_gateway_route" "e2_e1" {
  destination_cidr_block         = aws_vpc.e1.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway.e2.association_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.e2_e1_acceptor.transit_gateway_attachment_id
}

# E2 -> E1 *VPC* targeting the TGW in E2
resource "aws_route" "e2_e1_route" {
  route_table_id         = aws_vpc.e2.main_route_table_id
  destination_cidr_block = aws_vpc.e1.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.e2.id
}

# E1 -> E2 *transit* route
resource "aws_ec2_transit_gateway_route" "e1_e2_route" {
  provider                       = aws.use1
  destination_cidr_block         = aws_vpc.e2.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway.e1.association_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.e2_e1_acceptor.transit_gateway_attachment_id
}

# E1 -> E2 *VPC* targeting the TGW in E1
resource "aws_route" "e1_e2_route" {
  provider               = aws.use1
  route_table_id         = aws_vpc.e1.main_route_table_id
  destination_cidr_block = aws_vpc.e2.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.e1.id
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

resource "aws_ram_resource_share" "w2_share" {
  provider                  = aws.usw2
  name                      = "w2-resource-share"
  allow_external_principals = true
}

resource "aws_ram_principal_association" "w2_pa" {
  provider           = aws.usw2
  resource_share_arn = aws_ram_resource_share.w2_share.arn
  principal          = local.hvn_account_id
}

resource "aws_ram_resource_association" "w2_rra" {
  provider           = aws.usw2
  resource_share_arn = aws_ram_resource_share.w2_share.arn
  resource_arn       = aws_ec2_transit_gateway.w2.arn
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "example" {
  provider                      = aws.usw2
  transit_gateway_attachment_id = "tgw-attach-0041a0b68d833cd62"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "w2" {
  provider           = aws.usw2
  subnet_ids         = [data.aws_subnets.w2.ids[0]]
  transit_gateway_id = aws_ec2_transit_gateway.w2.id
  vpc_id             = data.aws_vpc.default_w2.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "w2_2" {
  provider           = aws.usw2
  subnet_ids         = [aws_subnet.w2_2.id]
  transit_gateway_id = aws_ec2_transit_gateway.w2.id
  vpc_id             = aws_vpc.w2_2.id
}

# intra W2 routing targeting the TGW in W2
resource "aws_route" "w2_172_to_6_route" {
  provider               = aws.usw2
  route_table_id         = data.aws_vpc.default_w2.main_route_table_id
  destination_cidr_block = aws_vpc.w2_2.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.w2.id
}

resource "aws_route" "e1_6_to_172_route" {
  provider               = aws.usw2
  route_table_id         = aws_vpc.w2_2.main_route_table_id
  destination_cidr_block = data.aws_vpc.default_w2.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.w2.id
}

#### E2 / W2 PEERING
resource "aws_ec2_transit_gateway_peering_attachment" "e2_w2_peering" {
  peer_region             = "us-west-2"
  peer_transit_gateway_id = aws_ec2_transit_gateway.w2.id
  transit_gateway_id      = aws_ec2_transit_gateway.e2.id

  tags = {
    Name = "E2 / W2 TGW Peering Requestor"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "e2_w2_acceptor" {
  provider                      = aws.usw2
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.e2_w2_peering.id

  tags = {
    Name = "E2 / W2 TGW Peering Acceptor"
  }
}

# E2 -> W2 *transit* route
resource "aws_ec2_transit_gateway_route" "e2_w2" {
  destination_cidr_block         = data.aws_vpc.default_w2.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway.e2.association_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.e2_w2_acceptor.transit_gateway_attachment_id
}

# E2 -> W2 *VPC* targeting the TGW in E2
resource "aws_route" "e2_w2_route" {
  route_table_id         = aws_vpc.e2.main_route_table_id
  destination_cidr_block = data.aws_vpc.default_w2.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.e2.id
}

# W2 -> E2 *transit* route
resource "aws_ec2_transit_gateway_route" "w2_e2_route" {
  provider                       = aws.usw2
  destination_cidr_block         = aws_vpc.e2.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway.w2.association_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.e2_w2_acceptor.transit_gateway_attachment_id
}

# W2 -> E2 *VPC* targeting the attachment
resource "aws_route" "w2_e2_route" {
  provider               = aws.usw2
  route_table_id         = data.aws_vpc.default_w2.main_route_table_id
  destination_cidr_block = aws_vpc.e2.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.w2.id
}
#### END E2 / W2 PEERING



#### E1 / W2 ROUTING WHICH IS ALL BROKEN

# E1 -> W2 *transit* route (targeting E2 TGW attachment)
# resource "aws_ec2_transit_gateway_route" "e1_w2" {
#   provider                       = aws.use1
#   destination_cidr_block         = data.aws_vpc.default_w2.cidr_block
#   transit_gateway_route_table_id = aws_ec2_transit_gateway.e1.association_default_route_table_id
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.e2_e1_acceptor.transit_gateway_attachment_id
# }

# E1 -> W2 *VPC* targeting the TGW
# resource "aws_route" "e1_w2_route" {
#   provider               = aws.use1
#   route_table_id         = aws_vpc.e1.main_route_table_id
#   destination_cidr_block = data.aws_vpc.default_w2.cidr_block
#   transit_gateway_id     = aws_ec2_transit_gateway.e1.id
# }

# W2 -> E1 *transit* route (targeting W2 TGW attachment)
# resource "aws_ec2_transit_gateway_route" "w2_e1" {
#   provider                       = aws.usw2
#   destination_cidr_block         = aws_vpc.e1.cidr_block
#   transit_gateway_route_table_id = aws_ec2_transit_gateway.w2.association_default_route_table_id
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.e2_w2_acceptor.transit_gateway_attachment_id
# }

# W2 -> E1 *VPC* targeting the TGW
# resource "aws_route" "w2_e1_route" {
#   provider               = aws.usw2
#   route_table_id         = data.aws_vpc.default_w2.main_route_table_id
#   destination_cidr_block = aws_vpc.e1.cidr_block
#   transit_gateway_id     = aws_ec2_transit_gateway.w2.id
# }
