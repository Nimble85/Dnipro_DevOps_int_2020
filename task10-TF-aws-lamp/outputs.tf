output "my_instance_id" {
  description = "InstanceID of our nginx_task_aws"
  value       = aws_instance.web1.id
}

output "Web1_ip" {
  description = "Instance Public IP  of our nginx_task_aws"
  value       = aws_instance.web1.public_ip
}
output "DB_ip" {
  description = "Instance Public IP  of our nginx_task_aws"
  value       = aws_instance.db.public_ip
}


output "my_sg_id" {
  description = "SecurityGroup of our WebSite"
  value       = aws_security_group.my_web.id
}

output "vpc_deafailt_id" {
  description = "VPC deafailt ID"
  value       = aws_vpc.default.id
}



output "id_1_public_subnet" {
  description = "ID public subnet in default VPC"
  value       = aws_subnet.eu-central-1a-public.id
}



output "route_table_for_pub_def" {
  description = "ID route table for public sub in default VPC"
  value       = aws_route_table.eu-central-1a-public.id
}


output "igw_default_vpc" {
  description = "aws_internet_gateway for default vpc"
  value       = aws_internet_gateway.default.id
}


