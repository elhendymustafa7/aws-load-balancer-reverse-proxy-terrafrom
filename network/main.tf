# create Main VPC ----------------------------------------------------

resource "aws_vpc" "iti_vpc" {
  cidr_block       = var.vpc-cidr
  tags = {
    Name = "MAIN-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.iti_vpc.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
        Name = "public_subnet${count.index}"
  }
}
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.iti_vpc.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
        Name = "private_subnet${count.index}"
  }

}

# create gw -----------------------------------------------------------

resource "aws_internet_gateway" "iti_gw" {
  vpc_id = aws_vpc.iti_vpc.id

  tags = {
    Name = "main-gw"
  }
}

# # create public route table ----------------------------------------------

resource "aws_route_table" "iti_public_rt" {
  vpc_id = aws_vpc.iti_vpc.id

  route {
    cidr_block = var.all-traffic
    gateway_id = aws_internet_gateway.iti_gw.id
  }

  tags = {
    Name = "iti_public_rt"
  }
}

# # create private route table  -----------------------------------------

resource "aws_eip" "iti_eip" {
    vpc              = true
}

resource "aws_nat_gateway" "iti_nat_gw" {
    allocation_id = aws_eip.iti_eip.id
    subnet_id     = aws_subnet.public_subnet[0].id

    tags = {
        Name = "gw NAT"
    }
}

resource "aws_route_table" "iti_private_rt" {
  vpc_id = aws_vpc.iti_vpc.id

  route {
    cidr_block = var.all-traffic
    gateway_id = aws_nat_gateway.iti_nat_gw.id
  }

  tags = {
    Name = "iti_private_rt"
  }
}

# # route table association -----------------------------------------------

resource "aws_route_table_association" "iti_public_rta" {
  count = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.iti_public_rt.id

}

resource "aws_route_table_association" "iti-private1-rta" {
  count = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.iti_private_rt.id

}



