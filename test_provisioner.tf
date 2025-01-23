# resource "aws_instance" "test" {
#   ami                    = data.aws_ami.rhel9.id
#   instance_type          = "t3.small"
#   key_name               = aws_key_pair.ubuntu.key_name
#   vpc_security_group_ids = [aws_security_group.allow_all.id]
#   tags = { Name = "test",
#     owner = "nick.philbrook@hashicorp.com",
#     TTL   = 0
#   }
#   lifecycle {
#     ignore_changes = [ami]
#   }

#   # Establishes connection to be used by all
#   # generic remote provisioners (i.e. file/remote-exec)
#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = var.ssh_private_key
#     host        = self.public_ip
#     script_path = "/home/ec2-user/foo.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "echo LOBSTER 2 >> /home/ec2-user/lobster"
#     ]
#   }
# }
