
data "aws_region" "current_region" {}

resource "aws_subnet" "phx_public_subnet_1" {
  vpc_id                  = aws_vpc.phx_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current_region.name}a"

  tags = {
    Name                     = "phx_public_subnet_1"
    Tier                     = "public"
    "kubernetes.io/role/elb" = 1
  }
}
resource "aws_subnet" "phx_public_subnet_2" {
  vpc_id                  = aws_vpc.phx_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current_region.name}b"
  tags = {
    Name                     = "phx_public_subnet_2"
    Tier                     = "public"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "phx_private_subnet_1" {
  vpc_id            = aws_vpc.phx_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${data.aws_region.current_region.name}a"
  tags = {
    Name                              = "phx_private_subnet_1"
    Tier                              = "private"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "phx_private_subnet_2" {
  vpc_id            = aws_vpc.phx_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${data.aws_region.current_region.name}b"
  tags = {
    Name                              = "phx_private_subnet_2"
    Tier                              = "private"
    "kubernetes.io/role/internal-elb" = 1
  }

}
