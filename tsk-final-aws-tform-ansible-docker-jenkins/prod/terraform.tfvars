aws_profile = "default"
region_run = "eu-central-1"
vpc_cidr   = "192.168.0.0/16"
cidrs_project      = {
  public1  = "192.168.1.0/24"
  public2  = "192.168.2.0/24"
  private1 = "192.168.3.0/24"
  private2 = "192.168.4.0/24"
  }

size_instance   = "t2.micro"
ami_project     = "ami-0e342d72b12109f91" # ubuntu 18.04
#ami_project     = "ami-0bad2b43a871348da"  # ubuntu 16.
public_key_path = "~/.ssh/jenkins.pem"
keypair_project = "jenkins"
user_name       = "ubuntu"
env_project     = "prod"

