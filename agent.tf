resource "aws_instance" "agent" {
  provider                    = aws.usw2
  ami                         = data.aws_ami.rhel9_w2.id
  associate_public_ip_address = true
  instance_type               = local.jump_instance_type
  key_name                    = aws_key_pair.acme_w2.key_name
  user_data                   = file("${path.module}/user_data.sh")
  vpc_security_group_ids      = [aws_security_group.allow_ssh_w2.id]
  tags = { Name = "agent",
    owner = "nick.philbrook@hashicorp.com",
    TTL   = 0
  }
  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_route53_record" "agent" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "agent.w2.${local.subdomain}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.agent.public_ip]
}
