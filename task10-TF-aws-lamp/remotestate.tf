
terraform {
 backend "s3" {
 encrypt = true
 bucket = "diplom.tfstate"
 dynamodb_table = "remotetf"
 region = "eu-central-1"
 key = "terraform-lamp.tfstate"
 }
 
}
