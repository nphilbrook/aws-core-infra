resource "aws_instance" "jump" {
  provider               = aws.usw2
  ami                    = data.aws_ami.rhel9.id
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
