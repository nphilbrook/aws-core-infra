
# us-east-2 allow all
resource "aws_security_group" "allow_all" {
  name        = "allow-all"
  description = "Allow all HTTP and SSH traffic and all egress traffic"

}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.allow_all.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.allow_all.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.allow_all.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "all_egress" {
  security_group_id = aws_security_group.allow_all.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}
# end us-east-2 allow all


# us-west-2 allow SSH/egress
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
# end us-west-2 allow SSH/egress

# us-west-2 2nd VPC allow SSH/egress
resource "aws_security_group" "allow_ssh_w2_2" {
  provider    = aws.usw2
  vpc_id      = aws_vpc.w2_2.id
  name        = "allow-ssh"
  description = "Allow all SSH traffic and all egress traffic"

}

resource "aws_vpc_security_group_ingress_rule" "ssh_w2_2" {
  provider          = aws.usw2
  security_group_id = aws_security_group.allow_ssh_w2_2.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "all_egress_w2_2" {
  provider          = aws.usw2
  security_group_id = aws_security_group.allow_ssh_w2_2.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}
# end us-west-2 2nd VPC allow SSH/egress

# us-west-2 3rd VPC allow SSH/egress
resource "aws_security_group" "allow_ssh_w2_3" {
  provider    = aws.usw2
  vpc_id      = aws_vpc.w2_3.id
  name        = "allow-ssh"
  description = "Allow all SSH traffic and all egress traffic"

}

resource "aws_vpc_security_group_ingress_rule" "ssh_w2_3" {
  provider          = aws.usw2
  security_group_id = aws_security_group.allow_ssh_w2_3.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "all_egress_w2_3" {
  provider          = aws.usw2
  security_group_id = aws_security_group.allow_ssh_w2_3.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}
# end us-west-2 2nd VPC allow SSH/egress

# us-east-2 allow SSH/egress
# resource "aws_security_group" "allow_ssh_e2" {
#   vpc_id      = aws_vpc.e2.id
#   name        = "allow-ssh"
#   description = "Allow all SSH traffic and all egress traffic"

# }

# resource "aws_vpc_security_group_ingress_rule" "ssh_e2" {
#   security_group_id = aws_security_group.allow_ssh_e2.id

#   cidr_ipv4   = "0.0.0.0/0"
#   from_port   = 22
#   ip_protocol = "tcp"
#   to_port     = 22
# }

# resource "aws_vpc_security_group_egress_rule" "all_egress_e2" {
#   security_group_id = aws_security_group.allow_ssh_e2.id

#   cidr_ipv4   = "0.0.0.0/0"
#   ip_protocol = -1
# }
# end us-east-2 allow SSH/egress

# us-east-1 allow SSH/egress
# resource "aws_security_group" "allow_ssh_e1" {
#   provider    = aws.use1
#   vpc_id      = aws_vpc.e1.id
#   name        = "allow-ssh"
#   description = "Allow all SSH traffic and all egress traffic"
# }

# resource "aws_vpc_security_group_ingress_rule" "ssh_e1" {
#   provider          = aws.use1
#   security_group_id = aws_security_group.allow_ssh_e1.id

#   cidr_ipv4   = "0.0.0.0/0"
#   from_port   = 22
#   ip_protocol = "tcp"
#   to_port     = 22
# }

# resource "aws_vpc_security_group_egress_rule" "all_egress_e1" {
#   provider          = aws.use1
#   security_group_id = aws_security_group.allow_ssh_e1.id

#   cidr_ipv4   = "0.0.0.0/0"
#   ip_protocol = -1
# }
# end us-east-1 allow SSH/egress


# us-east-1 2nd VPC allow SSH/egress
resource "aws_security_group" "allow_ssh_e1_2" {
  provider    = aws.use1
  vpc_id      = aws_vpc.e1_2.id
  name        = "allow-ssh"
  description = "Allow all SSH traffic and all egress traffic"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_e1_2" {
  provider          = aws.use1
  security_group_id = aws_security_group.allow_ssh_e1_2.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "all_egress_e1_2" {
  provider          = aws.use1
  security_group_id = aws_security_group.allow_ssh_e1_2.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}
# end us-east-1 2nd VPC allow SSH/egress


