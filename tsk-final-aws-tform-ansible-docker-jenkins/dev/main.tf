#variable  "aws_region"                         {}
variable   "aws_profile"                        {}
# data     "aws_availability_zones" "available" {}
variable   "vpc_cidr"                           {}
variable   "cidrs_project"                      {  type = "map"   }
variable   "public_key_path"                    {}
variable   "env_project"                        {}
variable   "ami_project"                        { description = "amazon linix ami id"  }
variable   "region_run"                         {}
variable   "size_instance"                      { description = "size instance"  }
variable   "keypair_project"                    {  description = "aws keypair name"    }
variable   "user_name"                          { description = "aws ssh login user" }
variable   "env_name_node_jenkins"              {}
variable   "env_label_slave_jenkins"            {}



provider "aws" {
  region = var.region_run
}
module "vpc" {
  source         = "../modules/vpc"
  cidrs          = var.cidrs_project 
  vpc_cidr_env   = var.vpc_cidr
}

module "db" {
  source                          = "../modules/db"
  ami                             = var.ami_project
  subnet_id                       = module.vpc.subnet_id_public1
  vpc_security_group_ids_instance = module.vpc.aws_security_group_dev_sg
  env_instance                    = var.env_project  
  keypair                         = var.keypair_project
  size_instance_dev               = var.size_instance
  subnet_id_instance              = module.vpc.subnet_id_public1
  role                            = module.s3.aws_iam_instance_profile_s3_read_profile_db_dev_name    
  name_node_jenkins               = var.env_name_node_jenkins
  label_slave_jenkins             = var.env_label_slave_jenkins

}

module "test" {
  source                          = "../modules/test"
  ami                             = var.ami_project
  subnet_id                       = module.vpc.subnet_id_public1
  vpc_security_group_ids_instance = module.vpc.aws_security_group_dev_sg
  env_instance                    = var.env_project
  keypair                         = var.keypair_project
  size_instance_dev               = var.size_instance
  subnet_id_instance              = module.vpc.subnet_id_public1
  role                            = module.s3.aws_iam_instance_profile_s3_read_profile_db_dev_name
  
}

module "s3"  {
  source                          = "../modules/s3"
}
terraform {
  backend "s3" {
  encrypt = true
  bucket = "diplom.tfstate"
  dynamodb_table = "remotetf"
  region = "eu-central-1"
  key = "terraform-dev.tfstate"
       }
}
