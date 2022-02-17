# Internet Gateway
resource "aws_internet_gateway" "phx_igw" {
  vpc_id = aws_vpc.phx_vpc.id

  tags = {
    Name = "phx_igw"
  }
}

# Nat Gateway
resource "aws_eip" "phx_ngw_eip" {
  vpc = true
}
resource "aws_nat_gateway" "phx_ngw_for_public_subnet_1" {
  allocation_id = aws_eip.phx_ngw_eip.id
  subnet_id     = aws_subnet.phx_public_subnet_1.id

  tags = {
    Name = "phx_ngw_for_public_subnet_1"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.phx_igw]
}
