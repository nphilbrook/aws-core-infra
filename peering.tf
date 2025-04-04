locals {
  peering_id = "pcx-0532c809c8da070db"
}

resource "aws_vpc_peering_connection_accepter" "accept_peer" {
  provider                  = aws.usw2
  vpc_peering_connection_id = local.peering_id
  auto_accept               = true
}

resource "aws_route" "r" {
  provider                  = aws.usw2
  route_table_id            = "rtb-04bc234149e745f3f"
  destination_cidr_block    = "10.2.0.0/16"
  vpc_peering_connection_id = local.peering_id
}
