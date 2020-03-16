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
/*  Public Subnet zone a */

resource "aws_subnet" "eu-central-1a-public" {
  vpc_id = aws_vpc.default.id

  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags =  {
      Name = "Public Subnet zone a"
  }
}

/*  Public Subnet zone b */

resource "aws_subnet" "eu-central-1b-public" {
  vpc_id = aws_vpc.default.id

  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-central-1b"

  tags =  {
      Name = "Public Subnet zone b"
  }
}

/*   create route table for public subnet zone a */

resource "aws_route_table" "eu-central-1a-public" {
  vpc_id = aws_vpc.default.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.default.id
  }
}

/*   create route table for public subnet zone b */

resource "aws_route_table" "eu-central-1b-public" {
  vpc_id = aws_vpc.default.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.default.id
  }
}

/* assotiate route table with public subnet az a */

resource "aws_route_table_association" "eu-central-1a-public" {
  subnet_id = aws_subnet.eu-central-1a-public.id
  route_table_id = aws_route_table.eu-central-1a-public.id
}

/* assotiate route table with public subnet az b*/

resource "aws_route_table_association" "eu-central-1b-public" {
  subnet_id = aws_subnet.eu-central-1b-public.id
  route_table_id = aws_route_table.eu-central-1b-public.id
}


