locals {
  subdomain = "dev.exceptbuses.com"
}

# NOTE - delegation must be set up manually on dns.he.net
# since this apex domain is not managed in Route53
resource "aws_route53_zone" "primary" {
  name = local.subdomain
}
