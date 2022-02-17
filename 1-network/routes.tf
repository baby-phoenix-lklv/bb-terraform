# public routes
resource "aws_default_route_table" "public_route_table" {
  default_route_table_id = aws_vpc.phx_vpc.default_route_table_id
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_default_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.phx_igw.id
}

resource "aws_route_table_association" "public_route_table_association_with_public_subnet_1" {
  route_table_id = aws_default_route_table.public_route_table.id
  subnet_id      = aws_subnet.phx_public_subnet_1.id
}
resource "aws_route_table_association" "public_route_table_association_with_public_subnet_2" {
  route_table_id = aws_default_route_table.public_route_table.id
  subnet_id      = aws_subnet.phx_public_subnet_2.id
}

# private routes
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.phx_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.phx_ngw_for_public_subnet_1.id
  }
  tags = {
    Name = "private_route_table"
  }
}

resource "aws_route_table_association" "private_route_table_association_with_private_subnet_1" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.phx_private_subnet_1.id
}

resource "aws_route_table_association" "private_route_table_association_with_private_subnet_2" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.phx_private_subnet_2.id
}
