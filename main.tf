module "network" {
    source = "./network"
    vpc-cidr = var.vpc-cidr
    all-traffic = var.all-traffic
    ec2-type = var.ec2-type
    private_subnet_cidr=var.private_subnet_cidr
    public_subnet_cidr=var.public_subnet_cidr
    availability_zone=var.availability_zone
}



