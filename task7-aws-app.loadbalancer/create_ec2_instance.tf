provider "aws" {
  region                 = "eu-central-1"
 }


resource "aws_instance" "nginx_aws" {
  ami                    = "ami-0d4c3eabb9e72650a"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.s3_read_profile.name
  vpc_security_group_ids = [aws_security_group.my_web.id]
  subnet_id              = aws_subnet.eu-central-1a-public.id
  associate_public_ip_address = true
  key_name               = "jenkins"
  tags = {
    Name    = "Nginx"
    Owner   = "Kozulenko Volodymyr"
    Project = "Terraform AWS task6"
  }
  user_data = file("user_data.sh")
}


