# Key features of project


### Terraform
- Dev Prod enveronments.
- State  on remote backend (S3 bucket and DynameDB table)
- Create S3-Read AIM Role and attach it to created instances. 
- Use provisioner local-exec (may be used for provisioning instances by local run ansible playbooks).
- Use modules - split all infra into 4 modules:
   - db (for creating ec2 instances test, dev, prod)
   - s3 (IAM S3 role for DEV enveronment)
   - s3_prod  (IAM S3 role for PROD enveronment)
   - vpc (vpc, subnets and etc.)

### Ansible
- Provisioning instance and  Docker&Jenkins (install Docker and dependency)
- Configure Slave nodes for Jenkins
- Create webhook on GitHub for Jenkins instance
- Restore from S3 bucket preconfigred Jenkins
- Create Jenkins docker container and run jenkins as service on host.

### Docker
- Run Container  with Jenkins inside

### Jenkins
- the pipeline triggered automatically after commit to repo;
- the deployment to dev occur automatically, manual approve to prod;



### Workflow:
Runing scrypt create.sh make folowing steps:
1. Creating enveronment DEV (instance named "DB", "Test|, "Jenkins" VPC subnet and etc)
2. Creating enveronment PROD (instance "DB" VPC subnet and etc)
3. Configure dy Ansible instances "Jenkins"





