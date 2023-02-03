data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}


resource "aws_instance" "public-ec2" {
    count = length(var.public_subnet_cidr)
    ami = data.aws_ami.ubuntu.id
    instance_type = var.ec2-type
    key_name ="tf-key-pair.pem"
    vpc_security_group_ids = [aws_security_group.iti-public-sg.id]
    subnet_id = aws_subnet.public_subnet[count.index].id
    associate_public_ip_address = true

    # user_data= file("network/ec2.sh")

    provisioner "remote-exec" {
        inline = [
            "sudo apt update -y",
            "sudo apt install nginx -y ",
            "echo 'server { \n listen 80 default_server; \n  listen [::]:80 default_server; \n  server_name _; \n  location / { \n  proxy_pass http://${aws_alb.private-alb.dns_name}; \n  } \n}' > default",
            "sudo mv default /etc/nginx/sites-enabled/default",
            "sudo systemctl restart nginx",
            "sudo apt install curl -y",
        ]

        connection {
            host        = self.public_ip
            type        = "ssh"
            user        = "ubuntu"
            private_key = file("tf-key-pair.pem")
        }
        
    }
    provisioner "local-exec" {
        command = "echo Public-ip : ${self.public_ip} >> all-ips.txt"
    }


    tags = {
        Name = "iti-proxy-ec2-public-${count.index}"
    }


}


resource "aws_instance" "private-ec2s" {
    count = length(var.public_subnet_cidr)
    
    ami           =  data.aws_ami.ubuntu.id
    
    instance_type = var.ec2-type
    
    subnet_id     = aws_subnet.private_subnet[count.index].id
    

    vpc_security_group_ids = [aws_security_group.iti-private-sg.id]
    
    user_data = file("network/ec2-userdata.sh")

    provisioner "local-exec" {
        command = "echo private-ip : ${self.private_ip} >> all-ips.txt"
    }
    
    tags = {
      Name = "iti-ec2-${count.index}"
    }
  
}


