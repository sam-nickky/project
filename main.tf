resource "aws_vpc" "main" {
    cidr_block = "172.16.0.0/16"
    enable_dns_support = true   
    enable_dns_hostnames = true


    tags = {
        Name = "Infra"
        Environment = "Test"
    }
}

resource "aws_subnet" "publicsn" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "172.16.10.0/24"
    availability_zone = "eu-north-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public Subnet"
        Environment = "Test"
    }
  
}

resource "aws_subnet" "privatesn" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "172.16.11.0/24"
    availability_zone = "eu-north-1b"
    tags = {
        Name = "Private Subnet"
        Environment = "Test"
    }
  
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet Gateway"
    Environment = "Test"

  } # ← FIXED closing brace here
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Public Route Table"
    Environment = "Test"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.publicsn.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_security_group" "web_sg" {
    name        = "web_sg"
    description = "Allow HTTP and SSH traffic"
    vpc_id      = aws_vpc.main.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"] 
    }
}

resource "aws_instance" "myname" {
    ami = "ami-042b4708b1d05f512" # Replace with a valid AMI ID
    instance_type = "m5.large" 
    subnet_id = aws_subnet.publicsn.id
    associate_public_ip_address = true
    key_name = "Project1" # Replace with your key pair name
    vpc_security_group_ids = [aws_security_group.web_sg.id]
 #   security_groups = [aws_security_group.web_sg.name]

    user_data = <<EOF
    #!/bin/bash
    apt update -y
    apt install -y apache2
    systemctl start apache2
    apt install docker.io -y
    systemctl start docker
    docker run -d -p 80:80 nginx   
EOF
    tags = {
        Name = "Web Server"
        Environment = "Test"
    }
}

output "aws_instance_public_ip" {
    value = aws_instance.myname.public_ip  
    description = "Public IP of the web server instance"

  }

  