# TASK
```
Homewok:
1. Create a new VPC 
2. Create a public and a private subnet 
3. Start a new EC2 instance 
4. Deploy an ACL and a security group 
5. Set up VPC peering
```
# SOLUTION
For solving task will be used Terraform.

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/diagram.png) 

Steps of solution:
1. Created IAM policy "S3ReadOnly"
2. Created IAM instancew profile
3. Created IAM role "s3_read_role"
4. Attached policy "S3ReadOnly" to role "s3_read_role"
5. Created VPC "Default" cidr_block="10.0.0.0/16" and VPC "Second" cidr_block="192.168.0.0/16" in eu-central-1a AZ
6. Created subnet "eu-central-1a-public" cidr_block="10.0.1.0/24" in VPC "Default"
7. Created subnet "eu-central-1a-private" cidr_block="10.0.2.0/24" in VPC "Default"
8. Created subnet "eu-central-1a-public-second" cidr_block="192.168.1.0/24" in VPC  "Second"
9. Created IGW for VPC "Default" and IGW for  VPC "Second"
10. Attached IGW for each VPS
11. Created route tables for subnets "eu-central-1a-public","eu-central-1a-private" and "eu-central-1a-public-second"
12. Assotiated route tables with subnets.
13. Created peering connection between VPC "Default" and VPC  "Second"
14. Created ACL and attach it to subnet "eu-central-1a-public"
15. Created Security group  "my_web" for VPC "Default", "my_web2" for VPC "Second"
16. Launched EC2 instanse named "Nginx" in "eu-central-1a-public" subnet and attached to instanse:
   - IAM role "s3_read_role"
   - Security group  "my_web"
   - user_data scripts user_data.sh
    Launched EC2 instanse named "Linux" in "eu-central-1a-private" subnet
    Launched EC2 instanse named "Nginx2" in "eu-central-1a-public-second" subnet and attached to instanse:
   - IAM role "s3_read_role"
   - Security group  "my_web2"
   - user_data scripts user_data.sh
17. While instanses runing, script does:
   - Update yum
   - Install nginx
   - Via AWS Cli syncing s3 backet "fenixra-site" to root folder Nginx /usr/share/nginx/html/
   - Maked chown for user nginx /usr/share/nginx/html/*
   - enable nginx and start.
18. Result - in subnet  "eu-central-1a-public" runing web server with a personal web site
19. Ping to subnets (check availability)

### 1. Created IAM policy "S3ReadOnly"
create_iam_policy.tf
```
resource "aws_iam_policy" "s3_read_policy" {
  name        = "S3ReadOnly"
  description = "S3ReadOnly policy"
  policy      = file("policys3bucket.json")
}
```
policys3bucket.json
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
```

### 2. Created IAM instancew profile
createiamprofile.tf
```
resource "aws_iam_instance_profile" "s3_read_profile" {
  name  = "s3_onlyread_profile"
  role  = aws_iam_role.ec2_s3_access_role.name
}
```

### 3. Created IAM role "s3_read_role"
createiamrole.tf
```
resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "s3_read_role"
  assume_role_policy = file("assumerolepolicy.json")
}
```
assumerolepolicy.json
```
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ec2.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
```
### 4. Attached policy "S3ReadOnly" to role "s3_read_role"
attaching_policy_and_role.tf
```
resource "aws_iam_policy_attachment" "attach_s3_read" {
  name       = "test_attachment_s3_read"
  roles      =["${aws_iam_role.ec2_s3_access_role.name}"]
  policy_arn = aws_iam_policy.s3_read_policy.arn
}
```
**5. Created VPC "Default" cidr_block="10.0.0.0/16" and VPC "Second" cidr_block="192.168.0.0/16" in eu-central-1a AZ**    
**6. Created subnet "eu-central-1a-public" cidr_block="10.0.1.0/24" in VPC "Default"**     
**7. Created subnet "eu-central-1a-private" cidr_block="10.0.2.0/24" in VPC "Default"**       
**8. Created subnet "eu-central-1a-public-second" cidr_block="192.168.1.0/24" in VPC  "Second"**      
**9. Created IGW for VPC "Default" and IGW for  VPC "Second"**     
**10. Attached IGW for each VPS**      
**11. Created route tables for subnets "eu-central-1a-public","eu-central-1a-private" and "eu-central-1a-public-second"**     
**12. Assotiated route tables with both subnets.**     
create_vpc_and_subnets.tf
```
resource "aws_vpc" "default" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "main_vpc"
  }
}
/* add IGW (internet gateway) */
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
   Name = "IGW for public subnet ,default VPC"
  }
}

/*  Public Subnet */
resource "aws_subnet" "eu-central-1a-public" {
  vpc_id = aws_vpc.default.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
  tags =  {
      Name = "Public Subnet"
  }

/*   create route table for public subnet */
resource "aws_route_table" "eu-central-1a-public" {
  vpc_id = aws_vpc.default.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.default.id
  }
  route {
      cidr_block = "192.168.1.0/24"
      gateway_id = aws_vpc_peering_connection.bridge.id
  }
  tags = {
      Name = "Public Subnet"
  }
}

/* assotiate route table with public subnet */
resource "aws_route_table_association" "eu-central-1a-public" {
  subnet_id = aws_subnet.eu-central-1a-public.id
  route_table_id = aws_route_table.eu-central-1a-public.id
}

/*  Private Subnet */
resource "aws_subnet" "eu-central-1a-private" {
  vpc_id = aws_vpc.default.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-central-1a"
  tags = {
      Name = "Private Subnet"
  }
}

/*   create route table for private  subnet */
resource "aws_route_table" "eu-central-1a-private" {
  vpc_id = aws_vpc.default.id
  route {
      cidr_block = "192.168.1.0/24"
      gateway_id = aws_vpc_peering_connection.bridge.id
   
  }
  tags = {
      Name = "Routetable Private Subnet"
  }
}

/* assotiate route table with private subnet */
resource "aws_route_table_association" "eu-central-1a-private" {
  subnet_id = aws_subnet.eu-central-1a-private.id
  route_table_id = aws_route_table.eu-central-1a-private.id
}

/* Create second VPC */
resource "aws_vpc" "second" {
  cidr_block       = "192.168.0.0/16"
  tags = {
    Name = "second_vpc"
  }
}
/* add IGW for second VPC (internet gateway) */

resource "aws_internet_gateway" "second" {
  vpc_id = aws_vpc.second.id
  tags = {
    Name = "IGW for public subnet , second  VPC"
  }
}

/*  Public Subnet second VPC */
resource "aws_subnet" "eu-central-1a-public-second" {
  vpc_id = aws_vpc.second.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "eu-central-1a"
  tags =  {
      Name = "Second Public Subnet in Second VPC"
  }
}

/*  create route table for public subnet in second VPC */
resource "aws_route_table" "eu-central-1a-public-second" {
  vpc_id = aws_vpc.second.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.second.id
  }
  route {
      cidr_block = "10.0.1.0/24"
      gateway_id = aws_vpc_peering_connection.bridge.id
  }
  tags = {
      Name = "Second Route table Public Subnet for second VPC"
  }
}

/* assotiate route table with public subnet second VPC */
resource "aws_route_table_association" "eu-central-1a-public-second" {
  subnet_id = aws_subnet.eu-central-1a-public-second.id
  route_table_id = aws_route_table.eu-central-1a-public-second.id
}
```
### 13. Created peering connection between VPC "Default" and VPC  "Second"
peering_connection.tf
```
resource "aws_vpc_peering_connection" "bridge" {
  peer_vpc_id   = aws_vpc.default.id
  vpc_id        = aws_vpc.second.id
}
```
### 14. Created ACL and attach it to subnet "eu-central-1a-public"
acl.tf
```
resource "aws_network_acl" "dmz-1" {
  vpc_id     = aws_vpc.default.id
  subnet_ids = [aws_subnet.eu-central-1a-public.id]
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0" 
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
  Name = "ACL for public default"
  }
}
```
### 15. Created Security group  "my_web" for VPC "Default"
aws_security_group.tf
```
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

```
### 16. Launched EC2 instanse in "eu-central-1a-public" subnet and attached to instanse:
create_ec2_instance.tf
```
provider "aws" {
  region                 = "eu-central-1"
 }


resource "aws_instance" "nginx_task_aws" {
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
resource "aws_instance" "nginx2_task_aws" {
  ami                    = "ami-0d4c3eabb9e72650a"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.s3_read_profile.name
  vpc_security_group_ids = [aws_security_group.my_web2.id]
  subnet_id              = aws_subnet.eu-central-1a-public-second.id
  associate_public_ip_address = true
  key_name               = "jenkins"
  tags = {
    Name    = "Nginx2"
    Owner   = "Kozulenko Volodymyr"
    Project = "Terraform AWS task6"
  }
  user_data = file("user_data.sh")
}
resource "aws_instance" "linux_task_aws" {
  ami                    = "ami-0d4c3eabb9e72650a"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.s3_read_profile.name
  vpc_security_group_ids = [aws_security_group.my_web.id]
  subnet_id              = aws_subnet.eu-central-1a-private.id
  associate_public_ip_address = true
  key_name               = "jenkins"
  tags = {
    Name    = "linux"
    Owner   = "Kozulenko Volodymyr"
    Project = "Terraform AWS task6"
  }
}
```
### 17. While instanse runing, script does:
user_data.sh
```
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install -y nginx1
sudo aws s3 sync s3://fenixra-site /usr/share/nginx/html/
sudo chown nginx:nginx -R /usr/share/nginx/html/
sudo systemctl enable nginx
sudo systemctl start nginx
```
### Results of "terraform apply" and Ping check
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic1.png)   
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic2.png)   
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic3.png)     
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic4.png)    
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic5.png)    
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic6.png)     
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic7.png)      
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic8.png)      
     
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic10.png)     
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic11.png) 
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic12.png) 
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic13.png)  
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic14.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic15.png)   

### terraform destroy 
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task6-aws-terraform-v1/screenshot/pic16.png) 
    

# terraform plan
```
[root@jenkins task6-aws-v1]# terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_instance_profile.s3_read_profile will be created
  + resource "aws_iam_instance_profile" "s3_read_profile" {
      + arn         = (known after apply)
      + create_date = (known after apply)
      + id          = (known after apply)
      + name        = "s3_onlyread_profile"
      + path        = "/"
      + role        = "s3_read_role"
      + roles       = (known after apply)
      + unique_id   = (known after apply)
    }

  # aws_iam_policy.s3_read_policy will be created
  + resource "aws_iam_policy" "s3_read_policy" {
      + arn         = (known after apply)
      + description = "S3ReadOnly policy"
      + id          = (known after apply)
      + name        = "S3ReadOnly"
      + path        = "/"
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = "s3:*"
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
    }

  # aws_iam_policy_attachment.attach_s3_read will be created
  + resource "aws_iam_policy_attachment" "attach_s3_read" {
      + id         = (known after apply)
      + name       = "test_attachment_s3_read"
      + policy_arn = (known after apply)
      + roles      = [
          + "s3_read_role",
        ]
    }

  # aws_iam_role.ec2_s3_access_role will be created
  + resource "aws_iam_role" "ec2_s3_access_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + max_session_duration  = 3600
      + name                  = "s3_read_role"
      + path                  = "/"
      + unique_id             = (known after apply)
    }

  # aws_instance.linux_task_aws will be created
  + resource "aws_instance" "linux_task_aws" {
      + ami                          = "ami-0d4c3eabb9e72650a"
      + arn                          = (known after apply)
      + associate_public_ip_address  = true
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + get_password_data            = false
      + host_id                      = (known after apply)
      + iam_instance_profile         = "s3_onlyread_profile"
      + id                           = (known after apply)
      + instance_state               = (known after apply)
      + instance_type                = "t2.micro"
      + ipv6_address_count           = (known after apply)
      + ipv6_addresses               = (known after apply)
      + key_name                     = "jenkins"
      + network_interface_id         = (known after apply)
      + password_data                = (known after apply)
      + placement_group              = (known after apply)
      + primary_network_interface_id = (known after apply)
      + private_dns                  = (known after apply)
      + private_ip                   = (known after apply)
      + public_dns                   = (known after apply)
      + public_ip                    = (known after apply)
      + security_groups              = (known after apply)
      + source_dest_check            = true
      + subnet_id                    = (known after apply)
      + tags                         = {
          + "Name"    = "linux"
          + "Owner"   = "Kozulenko Volodymyr"
          + "Project" = "Terraform AWS task6"
        }
      + tenancy                      = (known after apply)
      + volume_tags                  = (known after apply)
      + vpc_security_group_ids       = (known after apply)

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # aws_instance.nginx2_task_aws will be created
  + resource "aws_instance" "nginx2_task_aws" {
      + ami                          = "ami-0d4c3eabb9e72650a"
      + arn                          = (known after apply)
      + associate_public_ip_address  = true
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + get_password_data            = false
      + host_id                      = (known after apply)
      + iam_instance_profile         = "s3_onlyread_profile"
      + id                           = (known after apply)
      + instance_state               = (known after apply)
      + instance_type                = "t2.micro"
      + ipv6_address_count           = (known after apply)
      + ipv6_addresses               = (known after apply)
      + key_name                     = "jenkins"
      + network_interface_id         = (known after apply)
      + password_data                = (known after apply)
      + placement_group              = (known after apply)
      + primary_network_interface_id = (known after apply)
      + private_dns                  = (known after apply)
      + private_ip                   = (known after apply)
      + public_dns                   = (known after apply)
      + public_ip                    = (known after apply)
      + security_groups              = (known after apply)
      + source_dest_check            = true
      + subnet_id                    = (known after apply)
      + tags                         = {
          + "Name"    = "Nginx2"
          + "Owner"   = "Kozulenko Volodymyr"
          + "Project" = "Terraform AWS task6"
        }
      + tenancy                      = (known after apply)
      + user_data                    = "ccf50fa1ed669f459416f95a06336d729ccfc265"
      + volume_tags                  = (known after apply)
      + vpc_security_group_ids       = (known after apply)

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # aws_instance.nginx_task_aws will be created
  + resource "aws_instance" "nginx_task_aws" {
      + ami                          = "ami-0d4c3eabb9e72650a"
      + arn                          = (known after apply)
      + associate_public_ip_address  = true
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + get_password_data            = false
      + host_id                      = (known after apply)
      + iam_instance_profile         = "s3_onlyread_profile"
      + id                           = (known after apply)
      + instance_state               = (known after apply)
      + instance_type                = "t2.micro"
      + ipv6_address_count           = (known after apply)
      + ipv6_addresses               = (known after apply)
      + key_name                     = "jenkins"
      + network_interface_id         = (known after apply)
      + password_data                = (known after apply)
      + placement_group              = (known after apply)
      + primary_network_interface_id = (known after apply)
      + private_dns                  = (known after apply)
      + private_ip                   = (known after apply)
      + public_dns                   = (known after apply)
      + public_ip                    = (known after apply)
      + security_groups              = (known after apply)
      + source_dest_check            = true
      + subnet_id                    = (known after apply)
      + tags                         = {
          + "Name"    = "Nginx"
          + "Owner"   = "Kozulenko Volodymyr"
          + "Project" = "Terraform AWS task6"
        }
      + tenancy                      = (known after apply)
      + user_data                    = "ccf50fa1ed669f459416f95a06336d729ccfc265"
      + volume_tags                  = (known after apply)
      + vpc_security_group_ids       = (known after apply)

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # aws_internet_gateway.default will be created
  + resource "aws_internet_gateway" "default" {
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "IGW for public subnet ,default VPC"
        }
      + vpc_id   = (known after apply)
    }

  # aws_internet_gateway.second will be created
  + resource "aws_internet_gateway" "second" {
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "IGW for public subnet , second  VPC"
        }
      + vpc_id   = (known after apply)
    }

  # aws_network_acl.dmz-1 will be created
  + resource "aws_network_acl" "dmz-1" {
      + egress     = [
          + {
              + action          = "allow"
              + cidr_block      = "0.0.0.0/0"
              + from_port       = 0
              + icmp_code       = null
              + icmp_type       = null
              + ipv6_cidr_block = ""
              + protocol        = "-1"
              + rule_no         = 100
              + to_port         = 0
            },
        ]
      + id         = (known after apply)
      + ingress    = [
          + {
              + action          = "allow"
              + cidr_block      = "0.0.0.0/0"
              + from_port       = 0
              + icmp_code       = null
              + icmp_type       = null
              + ipv6_cidr_block = ""
              + protocol        = "-1"
              + rule_no         = 100
              + to_port         = 0
            },
        ]
      + owner_id   = (known after apply)
      + subnet_ids = (known after apply)
      + tags       = {
          + "Name" = "ACL for public default"
        }
      + vpc_id     = (known after apply)
    }

  # aws_route_table.eu-central-1a-private will be created
  + resource "aws_route_table" "eu-central-1a-private" {
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = [
          + {
              + cidr_block                = "192.168.1.0/24"
              + egress_only_gateway_id    = ""
              + gateway_id                = (known after apply)
              + instance_id               = ""
              + ipv6_cidr_block           = ""
              + nat_gateway_id            = ""
              + network_interface_id      = ""
              + transit_gateway_id        = ""
              + vpc_peering_connection_id = ""
            },
        ]
      + tags             = {
          + "Name" = "Routetable Private Subnet"
        }
      + vpc_id           = (known after apply)
    }

  # aws_route_table.eu-central-1a-public will be created
  + resource "aws_route_table" "eu-central-1a-public" {
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = [
          + {
              + cidr_block                = "0.0.0.0/0"
              + egress_only_gateway_id    = ""
              + gateway_id                = (known after apply)
              + instance_id               = ""
              + ipv6_cidr_block           = ""
              + nat_gateway_id            = ""
              + network_interface_id      = ""
              + transit_gateway_id        = ""
              + vpc_peering_connection_id = ""
            },
          + {
              + cidr_block                = "192.168.1.0/24"
              + egress_only_gateway_id    = ""
              + gateway_id                = (known after apply)
              + instance_id               = ""
              + ipv6_cidr_block           = ""
              + nat_gateway_id            = ""
              + network_interface_id      = ""
              + transit_gateway_id        = ""
              + vpc_peering_connection_id = ""
            },
        ]
      + tags             = {
          + "Name" = "Public Subnet"
        }
      + vpc_id           = (known after apply)
    }

  # aws_route_table.eu-central-1a-public-second will be created
  + resource "aws_route_table" "eu-central-1a-public-second" {
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = [
          + {
              + cidr_block                = "0.0.0.0/0"
              + egress_only_gateway_id    = ""
              + gateway_id                = (known after apply)
              + instance_id               = ""
              + ipv6_cidr_block           = ""
              + nat_gateway_id            = ""
              + network_interface_id      = ""
              + transit_gateway_id        = ""
              + vpc_peering_connection_id = ""
            },
          + {
              + cidr_block                = "10.0.1.0/24"
              + egress_only_gateway_id    = ""
              + gateway_id                = (known after apply)
              + instance_id               = ""
              + ipv6_cidr_block           = ""
              + nat_gateway_id            = ""
              + network_interface_id      = ""
              + transit_gateway_id        = ""
              + vpc_peering_connection_id = ""
            },
        ]
      + tags             = {
          + "Name" = "Second Route table Public Subnet for second VPC"
        }
      + vpc_id           = (known after apply)
    }

  # aws_route_table_association.eu-central-1a-private will be created
  + resource "aws_route_table_association" "eu-central-1a-private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # aws_route_table_association.eu-central-1a-public will be created
  + resource "aws_route_table_association" "eu-central-1a-public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # aws_route_table_association.eu-central-1a-public-second will be created
  + resource "aws_route_table_association" "eu-central-1a-public-second" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # aws_security_group.my_web will be created
  + resource "aws_security_group" "my_web" {
      + arn                    = (known after apply)
      + description            = "SG for AWS task6"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = -1
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "icmp"
              + security_groups  = []
              + self             = false
              + to_port          = -1
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 443
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
        ]
      + name                   = "Security Group for AWS task6"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name"  = "Security Group for AWS task6"
          + "Owner" = "Kozulenko Volodymyr"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_security_group.my_web2 will be created
  + resource "aws_security_group" "my_web2" {
      + arn                    = (known after apply)
      + description            = "SG 2 for AWS task6"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = -1
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "icmp"
              + security_groups  = []
              + self             = false
              + to_port          = -1
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 443
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
        ]
      + name                   = "Security Group 2 for AWS task6"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name"  = "Security Group for AWS task6"
          + "Owner" = "Kozulenko Volodymyr"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_subnet.eu-central-1a-private will be created
  + resource "aws_subnet" "eu-central-1a-private" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "eu-central-1a"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.2.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block                 = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "Private Subnet"
        }
      + vpc_id                          = (known after apply)
    }

  # aws_subnet.eu-central-1a-public will be created
  + resource "aws_subnet" "eu-central-1a-public" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "eu-central-1a"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.1.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block                 = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "Public Subnet"
        }
      + vpc_id                          = (known after apply)
    }

  # aws_subnet.eu-central-1a-public-second will be created
  + resource "aws_subnet" "eu-central-1a-public-second" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "eu-central-1a"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "192.168.1.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block                 = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "Second Public Subnet in Second VPC"
        }
      + vpc_id                          = (known after apply)
    }

  # aws_vpc.default will be created
  + resource "aws_vpc" "default" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "main_vpc"
        }
    }

  # aws_vpc.second will be created
  + resource "aws_vpc" "second" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "192.168.0.0/16"

      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "second_vpc"
        }
    }

  # aws_vpc_peering_connection.bridge will be created
  + resource "aws_vpc_peering_connection" "bridge" {
      + accept_status = (known after apply)
      + id            = (known after apply)
      + peer_owner_id = (known after apply)
      + peer_region   = (known after apply)
      + peer_vpc_id   = (known after apply)
      + vpc_id        = (known after apply)

      + accepter {
          + allow_classic_link_to_remote_vpc = (known after apply)
          + allow_remote_vpc_dns_resolution  = (known after apply)
          + allow_vpc_to_remote_classic_link = (known after apply)
        }

      + requester {
          + allow_classic_link_to_remote_vpc = (known after apply)
          + allow_remote_vpc_dns_resolution  = (known after apply)
          + allow_vpc_to_remote_classic_link = (known after apply)
        }
    }

Plan: 24 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

```

