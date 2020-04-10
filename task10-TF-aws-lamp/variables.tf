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

variable "s3_bucket_name" {
  description = "name s3 bucket for store tfstate"
  default = "task10.tfstate"
}

variable "remotetf" {
  description = "table dynamodb for lock state"
  default = "remotetf"
}

variable "key_for_lock_table" {
  description = "dynamodb key for lock state"
  default = "terraform-lamp.tfstate"
}