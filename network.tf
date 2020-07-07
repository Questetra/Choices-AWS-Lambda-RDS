resource "aws_vpc" "default-vpc" {
	cidr_block = var.vpc_cidr_block
	enable_dns_hostnames = true
    enable_dns_support   = true
    // instance_tenancy     = "default"
}

resource "aws_subnet" "default-subnet-2a" {
	cidr_block = cidrsubnet(aws_vpc.default-vpc.cidr_block, 4, 0)
	vpc_id = aws_vpc.default-vpc.id
	map_public_ip_on_launch = true
}

resource "aws_subnet" "default-subnet-2b" {
	cidr_block = cidrsubnet(aws_vpc.default-vpc.cidr_block, 4, 1)
	vpc_id = aws_vpc.default-vpc.id
	map_public_ip_on_launch = true
}

resource "aws_subnet" "default-subnet-2c" {
	cidr_block = cidrsubnet(aws_vpc.default-vpc.cidr_block, 4, 2)
	vpc_id = aws_vpc.default-vpc.id
	map_public_ip_on_launch = true
}

resource "aws_security_group" "default-vpc-sg" {
    name        = "default"
    description = "default VPC security group"
    vpc_id      = aws_vpc.default-vpc.id
}

resource "aws_security_group_rule" "default-vpc-sg-1" {
    from_port          = 0
    protocol           = "-1"
    security_group_id  = aws_security_group.default-vpc-sg.id
    self               = true
    to_port            = 0
    type               = "ingress"
}

resource "aws_security_group_rule" "default-vpc-sg" {
    cidr_blocks       = [var.my_ip]
    from_port         = 0
    protocol          = "-1"
    security_group_id = aws_security_group.default-vpc-sg.id
    self              = false
    to_port           = 0
    type              = "ingress"
}

resource "aws_security_group_rule" "default-vpc-sg-2" {
    cidr_blocks       = ["0.0.0.0/0"]
    from_port         = 0
    protocol          = "-1"
    security_group_id = aws_security_group.default-vpc-sg.id
    self              = false
    to_port           = 0
    type              = "egress"
}