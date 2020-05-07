output "aws_security_group_dev_sg" {
  description = "SecurityGroup of our WebSite"
  value       = aws_security_group.dev_sg.id
}


output "vpc_deafailt_id" {
  description = "VPC deafailt ID"
  value       = aws_vpc.vpc.id
}

output "id_1_public_1_vpc" {
  description = "ID public subnet in default VPC"
  value       = aws_subnet.public1.id
}

output "route_table_for_pub_def" {
  description = "ID route table for public sub in default VPC"
  value       = aws_route_table.public.id
}

output "igw_default_vpc" {
  description = "aws_internet_gateway for default vpc"
  value       = aws_internet_gateway.internet_gateway.id
}

output "aws_security_group_instance" {
  description = "id sg for db"
   value       = aws_security_group.public_sg.id
}

output "subnet_id_public1" {
  description = "subnet for db"
  value       = aws_subnet.public1.id
}

output "subnet_id_ec2" {
  description = "subnet for ec2"
    value       = aws_subnet.public1.id
}

output "aws_security_group_my_web_id" {
  description = "id sg for web"
  value       = aws_security_group.public_sg.id
}

#output "my_sg_id" {
#  description = "SecurityGroup of our WebSite"
#  value       = aws_security_group.my_web.id
#}

#output "vpc_deafailt_id" {
#  description = "VPC deafailt ID"
#  value       = aws_vpc.default.id
#}


#output "id_1_public_1_vpc" {
#  description = "ID public subnet in default VPC"
#  value       = aws_subnet.eu-central-1a-public.id
#}


#output "route_table_for_pub_def" {
#  description = "ID route table for public sub in default VPC"
#  value       = aws_route_table.eu-central-1a-public.id
#}


#output "igw_default_vpc" {
#  description = "aws_internet_gateway for default vpc"
#  value       = aws_internet_gateway.default.id
#}

#output "aws_security_group_db_id" {
#  description = "id sg for db"
#   value       = aws_security_group.db.id
#}
#output "subnet_id_db" {
#  description = "subnet for db"
#  value       = aws_subnet.eu-central-1a-public.id
#}
#output "subnet_id_ec2" {
#  description = "subnet for ec2"
#    value       = aws_subnet.eu-central-1a-public.id
#}
#output "aws_security_group_my_web_id" {
#  description = "id sg for web"
#  value       = aws_security_group.db.id
#}
    
