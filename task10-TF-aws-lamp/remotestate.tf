
terraform {
 backend "s3" {
 encrypt = true
 bucket = "task10.tfstate"
 dynamodb_table = "remotetf"
 region = "eu-central-1"
 key = "terraform-lamp.tfstate"
 }
 
}
