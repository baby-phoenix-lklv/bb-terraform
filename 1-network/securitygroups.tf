# public
# resource "aws_default_security_group" "phx_public_sg" {
#   vpc_id = aws_vpc.phx_vpc.id

#   ingress {
#     description = "TCP from internet"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "phx_public_sg"
#   }
# }

# private
# resource "aws_security_group" "phx_private_sg" {
#   vpc_id = aws_vpc.phx_vpc.id
#   name   = "phx_private_sg"

#   ingress {
#     description     = "TCP from internet"
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [aws_default_security_group.phx_public_sg.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "phx_private_sg"
#   }
# }
