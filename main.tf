provider "aws" {
    region = "eu-north-1"
}

resource "aws_instance" "example" {
    ami           = "ami-0c94855ba95c71c99" # Amazon Linux 2 AMI (us-east-1)
    instance_type = "t2.micro"

    tags = {
        Name = "Test-Infra"
    }
}