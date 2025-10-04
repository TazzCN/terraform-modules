data "aws_availability_zones" "az" { state = "available" }

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_internet_gateway" "igw" { vpc_id = aws_vpc.this.id }

resource "aws_subnet" "public" {
  for_each                = toset([0,1])
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[each.key]
  availability_zone       = data.aws_availability_zones.az.names[each.key]
  map_public_ip_on_launch = true
  tags = { Name = "${var.project_name}-public-${each.key}", Tier = "public" }
}

resource "aws_subnet" "private" {
  for_each          = toset([0,1])
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[each.key]
  availability_zone = data.aws_availability_zones.az.names[each.key]
  tags = { Name = "${var.project_name}-private-${each.key}", Tier = "private" }
}

resource "aws_eip" "nat" { 
  for_each = aws_subnet.public
  domain = "vpc" 
}

resource "aws_nat_gateway" "nat" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
}

resource "aws_route_table" "public" { vpc_id = aws_vpc.this.id }
resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "pub_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" { 
  for_each = aws_subnet.private
  vpc_id = aws_vpc.this.id
}
resource "aws_route" "priv_nat" {
  for_each               = aws_route_table.private
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}
resource "aws_route_table_association" "priv_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
