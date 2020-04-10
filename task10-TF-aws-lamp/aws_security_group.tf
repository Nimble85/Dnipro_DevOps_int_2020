resource "aws_security_group" "my_web" {
  name        = "SG for Web1 task10"
  description = "SGroup for Web1 task10"
  vpc_id      = aws_vpc.default.id

  dynamic "ingress" {
    for_each = ["80", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "SG for Web1 task10"
    Owner = "Kozulenko Volodymyr"
  }
}
#resource "aws_security_group" "my_web2" {
#  name        = "SG 2 for Web2 task10"
#  description = "SG 2 for AWS task6"
#  vpc_id      = aws_vpc.second.id
#
#  dynamic "ingress" {
#    for_each = ["80", "22"]
#    content {
#      from_port   = ingress.value
#      to_port     = ingress.value
#      protocol    = "tcp"
#      cidr_blocks = ["0.0.0.0/0"]
#    }
#  }
#
#  ingress {
#    from_port   = -1
#    to_port     = -1
#    protocol    = "icmp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  tags = {
#    Name  = "SG for Web2  task10"
#    Owner = "Kozulenko Volodymyr"
#  }
#}
resource "aws_security_group" "db" {
  name        = "SG for DB task10"
  description = "SG for db task10"
  vpc_id      = aws_vpc.default.id

  dynamic "ingress" {
    for_each = ["22", "3306"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Security Group for DB task10"
    Owner = "Kozulenko Volodymyr"
  }
}

