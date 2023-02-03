
resource "aws_alb" "public-alb" {
    
    name            = "public-alb"
    internal        = false
    security_groups = [aws_security_group.public-alb-sg.id]
    subnets = [aws_subnet.public_subnet[0].id,aws_subnet.public_subnet[1].id]
    tags = {
        name = "public-alb"
    }
}

resource "aws_alb_target_group" "public-tg" {
    
    name = "public-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.iti_vpc.id
    tags = {
        name = "public-tg"
    }
}

resource "aws_alb_listener" "public-alb-listener" {
    load_balancer_arn = aws_alb.public-alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = aws_alb_target_group.public-tg.arn
        type             = "forward"
    }
}


resource "aws_alb" "private-alb" {
    
    name            = "private-alb"
    internal        = true
    security_groups = [aws_security_group.private-alb-sg.id]
    subnets = [ aws_subnet.private_subnet[0].id,aws_subnet.private_subnet[1].id,]
    tags = {
        name = "private-alb"
    }
}

resource "aws_alb_target_group" "private-tg" {
    
    name = "private-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.iti_vpc.id
    tags = {
        name = "private-tg"
    }
}

resource "aws_alb_listener" "private-alb-listener" {
    load_balancer_arn = aws_alb.private-alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = aws_alb_target_group.private-tg.arn
        type             = "forward"
    }
}



resource "aws_alb_target_group_attachment" "public-target-group-attachment1" {
  count = length(var.public_subnet_cidr)
  target_group_arn = aws_alb_target_group.public-tg.arn
  target_id = aws_instance.public-ec2[count.index].id
  port = 80
}

resource "aws_alb_target_group_attachment" "private-target-group-attachment1" {
  count = length(var.public_subnet_cidr)
  target_group_arn = aws_alb_target_group.private-tg.arn
  target_id = aws_instance.private-ec2s[count.index].id
  port = 80
}

