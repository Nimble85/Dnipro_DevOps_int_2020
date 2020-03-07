resource "aws_vpc" "default" {
  cidr_block       = "10.0.0.0/16"
  
  tags = {
    Name = "main_vpc"
  }
}
/*
 add IGW (internet gateway)
*/

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

/*
  Public Subnet
*/

resource "aws_subnet" "eu-central-1a-public" {
  vpc_id = aws_vpc.default.id

  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags =  {
      Name = "Public Subnet"
  }
}

/*
  create route table for public subnet
*/

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

/*
 assotiate route table with public subnet
*/

resource "aws_route_table_association" "eu-central-1a-public" {
  subnet_id = aws_subnet.eu-central-1a-public.id
  route_table_id = aws_route_table.eu-central-1a-public.id
}


/*
  Private Subnet
*/
resource "aws_subnet" "eu-central-1a-private" {
  vpc_id = aws_vpc.default.id

  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-central-1a"

  tags = {
      Name = "Private Subnet"
  }
}
/*
 Create second VPC
*/

resource "aws_vpc" "second" {
  cidr_block       = "192.168.0.0/16"

  tags = {
    Name = "second_vpc"
  }
}
/*
 add IGW for second VPC (internet gateway)
*/

resource "aws_internet_gateway" "second" {
  vpc_id = aws_vpc.second.id
}

/*
  Public Subnet second VPC
*/

resource "aws_subnet" "eu-central-1a-public-second" {
  vpc_id = aws_vpc.second.id

  cidr_block = "192.168.1.0/24"
  availability_zone = "eu-central-1a"

  tags =  {
      Name = "Second Public Subnet in Second VPC"
  }
}

/*
  create route table for public subnet in second VPC
*/

resource "aws_route_table" "eu-central-1a-public-second" {
  vpc_id = aws_vpc.second.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.second.id
  }

  tags = {
      Name = "Second Route table Public Subnet for second VPC"
  }
}

/*
 assotiate route table with public subnet second VPC
*/

resource "aws_route_table_association" "eu-central-1a-public-second" {
  subnet_id = aws_subnet.eu-central-1a-public-second.id
  route_table_id = aws_route_table.eu-central-1a-public-second.id
}


