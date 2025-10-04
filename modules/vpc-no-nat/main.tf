data "aws_availability_zones" "az" { state = "available" }

// My own Isolated Network inside AWS region
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr # /16 gives 65536 IPs to use inside VPC
  enable_dns_support   = true # Allow Internal DNS resolution in VPC - Talk to other AWS services by DNS name
  enable_dns_hostnames = true # Assign DNS names to EC2 instances with public IPs
  tags = { Name = "${var.project_name}-vpc" } 
}

resource "aws_internet_gateway" "igw" { vpc_id = aws_vpc.this.id }

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = true
  tags = { 
    Name = "${var.project_name}-public-${count.index}"
    Tier = "public" 
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.az.names[count.index]
  tags = { 
    Name = "${var.project_name}-private-${count.index}" 
    Tier = "private" 
  }
}

resource "aws_route_table" "public" { 
  vpc_id = aws_vpc.this.id 
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "pub_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" { 
  count = length(aws_subnet.private)
  vpc_id = aws_vpc.this.id 
}

resource "aws_route_table_association" "priv_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
