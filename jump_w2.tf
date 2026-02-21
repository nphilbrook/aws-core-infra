data "aws_iam_policy_document" "agent_assume_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "agent_policy" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "agent_policy" {
  name   = "agent_policy"
  policy = data.aws_iam_policy_document.agent_policy.json
}

resource "aws_iam_role" "agent_role" {
  name               = "agent_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.agent_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "agent_policy_attachment" {
  role       = aws_iam_role.agent_role.name
  policy_arn = aws_iam_policy.agent_policy.arn
}

resource "aws_iam_instance_profile" "agent_profile" {
  name = "agent_profile"
  role = aws_iam_role.agent_role.name
}

# Shouldn't need this, all egress above?
# resource "aws_security_group" "allow_vault_w2" {
#   provider    = aws.usw2
#   name        = "allow-vault-peering"
#   description = "Allow Vault API traffic over the peering connection"
# }

# data "aws_ami" "rhel9_w2" {
#   provider    = aws.usw2
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["RHEL-9*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }

#   owners = ["309956199498"] # Red Hat
# }

# Create AWS keypair
resource "aws_key_pair" "acme_w2" {
  provider   = aws.usw2
  key_name   = "acme-w2"
  public_key = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC48Ys2HvlHglzLbwdfxt9iK2LATImoH8VG9vWzvuiRIsa8UQxbLbk6Gutx3MpB2FZywB3ZrZfw5MqivAtJXE2Os/QmgAZQxRpV15BTzrgvbqTKyibKnmRsCG59O8icftREKY6q/gvzr67QcMhMEZLDExS8c+zycQT1xCVg1ip5PwPAwMQRxtqLvV/5B85IsJuMZi3YymYaVSJgayYBA2eM/M8YInlIDKNqekHL/cUZFG2TP98NOODsY4kRyos4c8+jkULLCOGu0rLhA7rP3NsvEbcpCOI2lS5XgxnOHIpZ42V2xGId8IRDtK4wEGAHEWmOKdOsL4Qe5AwglHMmdkZU2HKdThOb5+8pf5BDe/I9aLB3k7vW5jcOm1dyHZ0pg/Tg9hJdFCCSBm0E4EJDRzI223chgwjf+XrMDB7DHTa29KU63rDeQme89y57HkgxXCIq4EVUKRaJS1PIUI7uJKMDryd2Au/W9z4nAbindFIxHMg/eC1aW0k90ri8FebvkX0= appleshampoo@delia
EOF
}

resource "aws_instance" "jump_w2" {
  provider                    = aws.usw2
  ami                         = data.hcp_packer_artifact.bastion.external_identifier
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.agent_profile.name
  instance_type               = local.jump_instance_type
  key_name                    = aws_key_pair.acme_w2.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh_w2.id]
  tags = { Name = "jumpw2",
    owner = "nick.philbrook@hashicorp.com",
    TTL   = 0
  }

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  # disable_api_termination = true

  # Gonna do double duty here - jump box and agent host
  user_data                   = templatefile("${path.module}/agent_user_data.tpl", { num_agents = 2 })
  user_data_replace_on_change = true
}

resource "aws_route53_record" "jump_w2" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "jumpw2.${local.subdomain}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.jump_w2.public_ip]
}

## NON-DEFAULT VPC
resource "aws_vpc" "w2_2" {
  provider   = aws.usw2
  cidr_block = "10.6.0.0/16"
  tags = {
    Name = "w2-nondefault2"
  }
}

resource "aws_internet_gateway" "w2_2" {
  provider = aws.usw2
  vpc_id   = aws_vpc.w2_2.id
}

resource "aws_route" "w2_2" {
  provider               = aws.usw2
  route_table_id         = aws_vpc.w2_2.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.w2_2.id
}

resource "aws_subnet" "w2_2" {
  provider          = aws.usw2
  vpc_id            = aws_vpc.w2_2.id
  cidr_block        = "10.6.0.0/24"
  availability_zone = "us-west-2a"
}

# resource "aws_instance" "jump_w2_2" {
#   provider                    = aws.usw2
#   ami                         = data.aws_ami.rhel9_w2.id
#   associate_public_ip_address = true
#   subnet_id                   = aws_subnet.w2_2.id
#   instance_type               = local.jump_instance_type
#   key_name                    = aws_key_pair.acme_w2.key_name
#   vpc_security_group_ids      = [aws_security_group.allow_ssh_w2_2.id]
#   tags = { Name = "jumpw2-2",
#     owner = "nick.philbrook@hashicorp.com",
#     TTL   = 0
#   }
#   lifecycle {
#     ignore_changes = [ami]
#   }
# }

# resource "aws_route53_record" "jump_w2_2" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = "jumpw2-2.${local.subdomain}"
#   type    = "A"
#   ttl     = 300
#   records = [aws_instance.jump_w2_2.public_ip]
# }

## NON-DEFAULT VPC 2 ELECTRIC BOOGALOO
resource "aws_vpc" "w2_3" {
  provider   = aws.usw2
  cidr_block = "10.7.0.0/16"
  tags = {
    Name = "w2-nondefault3"
  }
}

resource "aws_internet_gateway" "w2_3" {
  provider = aws.usw2
  vpc_id   = aws_vpc.w2_3.id
}

resource "aws_route" "w2_3" {
  provider               = aws.usw2
  route_table_id         = aws_vpc.w2_3.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.w2_3.id
}

resource "aws_subnet" "w2_3" {
  provider          = aws.usw2
  vpc_id            = aws_vpc.w2_3.id
  cidr_block        = "10.7.0.0/24"
  availability_zone = "us-west-2b"
}

# resource "aws_instance" "jump_w2_3" {
#   provider                    = aws.usw2
#   ami                         = data.aws_ami.rhel9_w2.id
#   associate_public_ip_address = true
#   subnet_id                   = aws_subnet.w2_3.id
#   instance_type               = local.jump_instance_type
#   key_name                    = aws_key_pair.acme_w2.key_name
#   vpc_security_group_ids      = [aws_security_group.allow_ssh_w2_3.id]
#   tags = { Name = "jumpw2-3",
#     owner = "nick.philbrook@hashicorp.com",
#     TTL   = 0
#   }
#   lifecycle {
#     ignore_changes = [ami]
#   }
# }

# resource "aws_route53_record" "jump_w2_3" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = "jumpw2-3.${local.subdomain}"
#   type    = "A"
#   ttl     = 300
#   records = [aws_instance.jump_w2_3.public_ip]
# }
