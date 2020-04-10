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
}

/*   create route table for public subnet */

resource "aws_route_table" "eu-central-1a-public" {
  vpc_id = aws_vpc.default.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.default.id
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



