
terraform {
 backend "s3" {
 encrypt = true
 bucket = var.s3_bucket_name
 dynamodb_table = var.remotetf
 region = var.region_run
 key = var.key_for_lock_table
 }
 
}
