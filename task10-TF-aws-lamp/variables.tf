variable "ami" {
  description = "amazon linix ami id"
  default = "ami-0ec1ba09723e5bfac"
}

variable "region_run" {
  description = "region"
  default = "eu-central-1"
}

variable "size_instance" {
  description = "size instance"
  default = "t2.micro"
}

variable "keypair" {
  description = "aws keypair name"
    default = "jenkins"
}
variable "user_name" {
  description = "aws ssh login user"
      default = "ec2-user"
}
