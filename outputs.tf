output "accepter_vpc_id" {
  value = aws_vpc_peering_connection_accepter.accept_peer.vpc_id
}

output "peer_vpc_id" {
  value = aws_vpc_peering_connection_accepter.accept_peer.peer_vpc_id
}

output "peer_owner_id" {
  value = aws_vpc_peering_connection_accepter.accept_peer.peer_owner_id
}

output "accepter" {
  value = aws_vpc_peering_connection_accepter.accept_peer.accepter
}

output "requester" {
  value = aws_vpc_peering_connection_accepter.accept_peer.requester
}

output "aws_ec2_transit_gateway_id" {
  value = aws_ec2_transit_gateway.w2.id
}

output "aws_ram_resource_share_arn" {
  value = aws_ram_resource_share.w2_share.arn
}
