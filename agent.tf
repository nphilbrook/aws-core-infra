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

# resource "aws_instance" "agent" {
#   provider                    = aws.usw2
#   ami                         = data.aws_ami.rhel9_w2.id
#   associate_public_ip_address = true
#   iam_instance_profile        = aws_iam_instance_profile.agent_profile.name
#   instance_type               = local.jump_instance_type
#   key_name                    = aws_key_pair.acme_w2.key_name
#   user_data                   = file("${path.module}/user_data.sh")
#   vpc_security_group_ids      = [aws_security_group.allow_ssh_w2.id]
#   tags = { Name = "agent",
#     owner = "nick.philbrook@hashicorp.com",
#     TTL   = 0
#   }
#   lifecycle {
#     ignore_changes = [ami]
#   }
# }

# resource "aws_route53_record" "agent" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = "agent.w2.${local.subdomain}"
#   type    = "A"
#   ttl     = 300
#   records = [aws_instance.agent.public_ip]
# }

resource "aws_instance" "agent_supervised" {
  provider                    = aws.usw2
  ami                         = data.aws_ami.rhel9_w2.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.agent_profile.name
  instance_type               = local.jump_instance_type
  key_name                    = aws_key_pair.acme_w2.key_name
  user_data                   = templatefile("${path.module}/agent_user_data.sh", { num_agents = 2 })
  user_data_replace_on_change = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_w2.id]
  tags = { Name = "agent-sup",
    owner = "nick.philbrook@hashicorp.com",
    TTL   = 0
  }
  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_route53_record" "agent_supervised" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "agent-sup.w2.${local.subdomain}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.agent_supervised.public_ip]
}
