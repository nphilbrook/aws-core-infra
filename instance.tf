data "aws_ami" "rhel9" {
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
resource "aws_key_pair" "ubuntu" {
  key_name   = "terraform-key"
  public_key = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC48Ys2HvlHglzLbwdfxt9iK2LATImoH8VG9vWzvuiRIsa8UQxbLbk6Gutx3MpB2FZywB3ZrZfw5MqivAtJXE2Os/QmgAZQxRpV15BTzrgvbqTKyibKnmRsCG59O8icftREKY6q/gvzr67QcMhMEZLDExS8c+zycQT1xCVg1ip5PwPAwMQRxtqLvV/5B85IsJuMZi3YymYaVSJgayYBA2eM/M8YInlIDKNqekHL/cUZFG2TP98NOODsY4kRyos4c8+jkULLCOGu0rLhA7rP3NsvEbcpCOI2lS5XgxnOHIpZ42V2xGId8IRDtK4wEGAHEWmOKdOsL4Qe5AwglHMmdkZU2HKdThOb5+8pf5BDe/I9aLB3k7vW5jcOm1dyHZ0pg/Tg9hJdFCCSBm0E4EJDRzI223chgwjf+XrMDB7DHTa29KU63rDeQme89y57HkgxXCIq4EVUKRaJS1PIUI7uJKMDryd2Au/W9z4nAbindFIxHMg/eC1aW0k90ri8FebvkX0= appleshampoo@delia
EOF
}

resource "aws_instance" "tfe" {
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

locals {
  subdomain = "dev.exceptbuses.com"
}

# NOTE - delegation must be set up manually on dns.he.net
# since this apex domain is not managed in Route53
resource "aws_route53_zone" "primary" {
  name = "dev.exceptbuses.com"
}

resource "aws_route53_record" "tfe" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "tfe.${local.subdomain}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.tfe.public_ip]
}

# module "acm" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~>5.0.0"

#   domain_name       = "tfe.${local.subdomain}"
#   zone_id           = aws_route53_zone.primary.id
#   validation_method = "DNS"
# }

# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "~>9.9.0"

#   name    = local.subdomain
#   enable_deletion_protection = false

#   # Security Group
#   security_group_ingress_rules = {
#     all_http = {
#       from_port   = 80
#       to_port     = 80
#       ip_protocol = "tcp"
#       description = "HTTP web traffic"
#       cidr_ipv4   = "0.0.0.0/0"
#     }
#     all_https = {
#       from_port   = 443
#       to_port     = 443
#       ip_protocol = "tcp"
#       description = "HTTPS web traffic"
#       cidr_ipv4   = "0.0.0.0/0"
#     }
#   }
#   security_group_egress_rules = {
#     all = {
#       ip_protocol = "-1"
#       cidr_ipv4   = "0.0.0.0/0"
#     }
#   }

#   listeners = {
#     fixed-response = {
#       port     = 80
#       protocol = "HTTP"
#       fixed_response = {
#         content_type = "text/plain"
#         message_body = "Hella World\n"
#         status_code  = "200"
#       }
#     }

#     tfe-https = {
#       port                        = 443
#       protocol                    = "HTTPS"
#       ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
#       certificate_arn             = module.acm.acm_certificate_arn

#       forward = {
#         target_group_key = "tfe"
#       }

#       rules = {
#         fixed-response = {
#           actions = [{
#             type         = "fixed-response"
#             content_type = "text/plain"
#             status_code  = 200
#             message_body = "Hella World but secure\n"
#           }]

#           conditions = [{
#             http_header = {
#               http_header_name = "x-Gimme-Fixed-Response"
#               values           = ["yes", "please", "right now"]
#             }
#           }]
#         }
#       }
#     }
#   }
#   target_groups = {
#     "tfe" = {
#       target_type       = "ip"
#       target_id         = aws_instance.tfe.private_ip
#       name_prefix       = "tfe-"
#       protocol          = "HTTP"
#       port              = 443
#       create_attachment = false
#       # health_check = {
#       #   enabled  = true
#       #   interval = 30
#       #   path     = "/health"
#       #   protocol = "HTTP"
#       #   matcher  = "200"
#       # }
#     }
#   }

#   # Route53 Record(s)
#   route53_records = {
#     A = {
#       name    = "tfe.${local.subdomain}"
#       type    = "A"
#       zone_id = aws_route53_zone.primary.id
#     }
#   }
# }
