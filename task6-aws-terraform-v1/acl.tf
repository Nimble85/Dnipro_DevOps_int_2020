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
