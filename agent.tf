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

# resource "aws_instance" "agent_supervised" {
#   count                       = local.num_agent_vms
#   provider                    = aws.usw2
#   ami                         = data.aws_ami.rhel9_w2.id
#   associate_public_ip_address = true
#   iam_instance_profile        = aws_iam_instance_profile.agent_profile.name
#   instance_type               = local.jump_instance_type
#   key_name                    = aws_key_pair.acme_w2.key_name
#   metadata_options {
#     http_tokens = "required"
#   }
#   user_data                   = templatefile("${path.module}/agent_user_data.tpl", { num_agents = 2 })
#   user_data_replace_on_change = true
#   vpc_security_group_ids      = [aws_security_group.allow_ssh_w2.id]
#   tags = { Name = "agent-sup-${count.index}",
#     owner = "nick.philbrook@hashicorp.com",
#     TTL   = 0
#   }
#   lifecycle {
#     ignore_changes = [ami]
#   }
# }

# resource "aws_route53_record" "agent_supervised" {
#   count   = local.num_agent_vms
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = "agent-sup-${count.index}.w2.${local.subdomain}"
#   type    = "A"
#   ttl     = 300
#   records = [aws_instance.agent_supervised[count.index].public_ip]
# }
