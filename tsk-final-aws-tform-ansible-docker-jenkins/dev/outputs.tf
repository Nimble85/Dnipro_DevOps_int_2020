output "public_ip_dev_db" {
  description = "Instance DEV Public IP "
    value       = module.db.public_db_ip
}

output "public_ip_test" {
  description = "Instance Test Public IP "
    value       = module.test.public_test_ip
}

output "public_ip_jenkins" {
  description = "Instance Jenkins Public IP "
    value       = module.test.public_jenkins_ip
}
    
