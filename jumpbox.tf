resource "aws_security_group" "allow_ssh_w2" {
  provider    = aws.usw2
  name        = "allow-ssh"
  description = "Allow all SSH traffic and all egress traffic"

}

resource "aws_vpc_security_group_ingress_rule" "ssh_w2" {
  provider          = aws.usw2
  security_group_id = aws_security_group.allow_ssh_w2.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "all_egress_w2" {
  provider          = aws.usw2
  security_group_id = aws_security_group.allow_ssh_w2.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

data "aws_ami" "rhel9_usw2" {
  provider    = aws.usw2
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-9*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["309956199498"] # Red Hat
}

# Create AWS keypair
resource "aws_key_pair" "acme_w2" {
  provider   = aws.usw2
  key_name   = "acme-w2"
  public_key = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC48Ys2HvlHglzLbwdfxt9iK2LATImoH8VG9vWzvuiRIsa8UQxbLbk6Gutx3MpB2FZywB3ZrZfw5MqivAtJXE2Os/QmgAZQxRpV15BTzrgvbqTKyibKnmRsCG59O8icftREKY6q/gvzr67QcMhMEZLDExS8c+zycQT1xCVg1ip5PwPAwMQRxtqLvV/5B85IsJuMZi3YymYaVSJgayYBA2eM/M8YInlIDKNqekHL/cUZFG2TP98NOODsY4kRyos4c8+jkULLCOGu0rLhA7rP3NsvEbcpCOI2lS5XgxnOHIpZ42V2xGId8IRDtK4wEGAHEWmOKdOsL4Qe5AwglHMmdkZU2HKdThOb5+8pf5BDe/I9aLB3k7vW5jcOm1dyHZ0pg/Tg9hJdFCCSBm0E4EJDRzI223chgwjf+XrMDB7DHTa29KU63rDeQme89y57HkgxXCIq4EVUKRaJS1PIUI7uJKMDryd2Au/W9z4nAbindFIxHMg/eC1aW0k90ri8FebvkX0= appleshampoo@delia
EOF
}

resource "aws_instance" "jump" {
  provider               = aws.usw2
  ami                    = data.aws_ami.rhel9_usw2.id
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.acme_w2.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_w2.id]
  tags = { Name = "tfe",
    owner = "nick.philbrook@hashicorp.com",
    TTL   = 0
  }
  lifecycle {
    ignore_changes = [ami]
  }
}
