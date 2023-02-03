
# security groups ------------------------------------------------------

resource "aws_security_group" "iti-private-sg" {
    
    vpc_id      = aws_vpc.iti_vpc.id


    ingress {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        security_groups = [aws_security_group.private-alb-sg.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.all-traffic]
    }

    tags = {
        Name = "iti-private-sg"
    }
}

resource "aws_security_group" "iti-public-sg" {
    
    vpc_id      = aws_vpc.iti_vpc.id

    ingress {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = [var.all-traffic]
    }

    ingress {
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = [var.all-traffic]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.all-traffic]
    }

    tags = {
        Name = "iti-public-sg"
        description = "iti-public-sg1"
    }
}

resource "aws_security_group" "public-alb-sg" {

    vpc_id = aws_vpc.iti_vpc.id

    description = "security group for public ALB"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = [var.all-traffic]
    }


    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.all-traffic]
    }



    tags = {
        name = "public-lb-sg"
    }
}

resource "aws_security_group" "private-alb-sg" {

    vpc_id = aws_vpc.iti_vpc.id

    description = "security group for private ALB"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.iti-public-sg.id]
    }


    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.all-traffic]
    }



    tags = {
        name = "private-alb-sg"
    }
}
