# Key features of project


### Terraform
- Dev Prod environment.
- State  on remote backend (S3 bucket and DynameDB table)
- Creating S3-Read AIM Role and attach it to created instances. 
- Using provisioner local-exec (may be used for provisioning instances by local run ansible playbooks).
- Using modules - all infra split into 4 modules:
   - db (for creating ec2 instances test, dev, prod)
   - s3 (IAM S3 role for DEV enveronment)
   - s3_prod  (IAM S3 role for PROD enveronment)
   - vpc (vpc, subnets and etc.)

### Ansible
- Using Ansible Roles
- Provisioning instance and  Docker&Jenkins (install Docker and dependency)
- Configuring Slave nodes for Jenkins
- Creating webhook on GitHub for Jenkins instance
- Restoring from S3 bucket preconfigred Jenkins
- Creating Jenkins docker container and run jenkins as service on host.

### Docker
- Runing Container  with Jenkins inside

### Jenkins
- the pipeline triggered automatically after commit to repo;
- the deployment to dev occur automatically, manual approve to prod;



### Workflow:
Runing scrypt create.sh will make folowing steps:
1. Creating enveronment DEV (instance named "DB", "Test|, "Jenkins" VPC subnet and etc)
2. Creating enveronment PROD (instance "DB" VPC subnet and etc)
3. Configure dy Ansible instances "Jenkins"
4. Creating webhook for Github





