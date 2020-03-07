output "my_instance_id" {
  description = "InstanceID of our nginx_task_aws"
  value       = aws_instance.nginx_task_aws.id
}

output "my_instance_ip" {
  description = "Instance Public IP  of our nginx_task_aws"
  value       = aws_instance.nginx_task_aws.public_ip
}

output "my_sg_id" {
  description = "SecurityGroup of our WebSite"
  value       = aws_security_group.my_web.id
}

output "vpc_deafailt_id" {
  description = "VPC deafailt ID"
  value       = aws_vpc.default.id
}

output "vpc_second_id" {
  description = "VPC second ID "
  value       = aws_vpc.second.id
}

output "id_1_public_1_vpc" {
  description = "ID public subnet in default VPC"
  value       = aws_subnet.eu-central-1a-public.id
}

output "id_1_private_1_vpc" {
  description = "ID private subnet in defailt VPC"
  value       =  aws_subnet.eu-central-1a-private.id
}

output "route_table_for_pub_def" {
  description = "ID route table for public sub in default VPC"
  value       = aws_route_table.eu-central-1a-public.id
}

output "route_table_for_pub_second" {
  description = "ID route table for public sub in second VPC"
  value       = aws_route_table.eu-central-1a-public-second.id
}

output "igw_default_vpc" {
  description = "aws_internet_gateway for default vpc"
  value       = aws_internet_gateway.default.id
}

output "igw_second_vpc" {
  description = "aws_internet_gateway for second vpc"
  value       = aws_internet_gateway.second.id
}

output "id_peering" {
  description = "ID peering between second and default vpc"
  value       = aws_vpc_peering_connection.bridge.id
}

