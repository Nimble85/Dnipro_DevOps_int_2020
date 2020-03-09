resource "aws_security_group" "my_web" {
  name        = "Security Group for AWS task6"
  description = "SG for AWS task6"
  vpc_id      = aws_vpc.default.id

  dynamic "ingress" {
    for_each = ["80", "22", "443"]
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
    Name  = "Security Group for AWS task6"
    Owner = "Kozulenko Volodymyr"
  }
}
resource "aws_security_group" "my_web2" {
  name        = "Security Group 2 for AWS task6"
  description = "SG 2 for AWS task6"
  vpc_id      = aws_vpc.second.id

  dynamic "ingress" {
    for_each = ["80", "22", "443"]
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
    Name  = "Security Group for AWS task6"
    Owner = "Kozulenko Volodymyr"
  }
}

