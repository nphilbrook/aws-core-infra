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
