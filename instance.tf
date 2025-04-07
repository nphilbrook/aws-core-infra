# Candidate for deletion - turned off and has a security vulnerability
resource "aws_instance" "tfe" {
  ami                    = data.aws_ami.rhel9_e2.id
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.ubuntu.key_name
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  tags = { Name = "tfe",
    owner = "nick.philbrook@hashicorp.com",
    TTL   = 0
  }
  lifecycle {
    ignore_changes = [ami]
  }
}


# resource "aws_route53_record" "tfe" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = "tfe.${local.subdomain}"
#   type    = "A"
#   ttl     = 300
#   records = [aws_instance.tfe.public_ip]
# }
