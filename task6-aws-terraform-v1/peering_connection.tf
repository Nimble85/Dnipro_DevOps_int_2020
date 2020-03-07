resource "aws_vpc_peering_connection" "bridge" {
  
  peer_vpc_id   = aws_vpc.default.id
  vpc_id        = aws_vpc.second.id
}
