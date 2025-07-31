variable "ami" {
    description = "AMI ID for the EC2 instance"
    type        = string
    default = "ami-042b4708b1d05f512"
}

variable "subnet_id" {
    description = "ID of the subnet where the EC2 instance will be launched"
    type        = string

}
variable "key_name" {
    description = "key detais"
    type = string
    default = "Project1"
}
