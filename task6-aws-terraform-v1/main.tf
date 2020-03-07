provider "aws" {
  region                 = "eu-central-1"
 }

resource "aws_instance" "nginx_task_aws" {
  ami                    = "ami-0d4c3eabb9e72650a"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  key_name               = "jenkins"
  tags = {
    Name    = "Nginx"
    Owner   = "Kozulenko Volodymyr"
    Project = "Terraform AWS task"
  }
  user_data = file("user_data.sh")


resource "aws_security_group" "my_webserver" {
  name        = "Security Group for Project"
  description = "SG for project"


  dynamic "ingress" {
    for_each = ["80", "22", "8081"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Security Group for Project"
    Owner = "Kozulenko Volodymyr"
  }
}

