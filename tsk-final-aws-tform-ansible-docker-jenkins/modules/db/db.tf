variable "ami"                             {}
variable "size_instance_dev"               {}
variable "keypair"                         {}
variable "vpc_security_group_ids_instance" {}
variable "subnet_id"                       {}
variable "env_instance"                    {}
variable "subnet_id_instance"              {}
variable "role"                            {} 
variable "name_node_jenkins"               {} 
variable "label_slave_jenkins"             {}

resource "aws_instance" "db" {
  ami                         = var.ami
  instance_type               = var.size_instance_dev
  vpc_security_group_ids      = [var.vpc_security_group_ids_instance]
  iam_instance_profile        = var.role
  associate_public_ip_address = true
  key_name                    = var.keypair
  subnet_id                   = var.subnet_id_instance
  user_data                   = file("../files/user_data_test.sh")

  
  tags = {
    Name    = "DB"
    Env     =  var.env_instance
    Owner   = "Kozulenko Volodymyr"
  }

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > aws_hosts_db
[dev]
${aws_instance.db.public_ip}
EOF
EOD
  }
  
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >  config.xml
<slave>
  <name>${var.name_node_jenkins}</name>
  <description>slave on Test instance Dev Env</description>
  <remoteFS>/home/ubuntu/jenkins_slave</remoteFS>
  <numExecutors>1</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.31.2">
    <host>${aws_instance.db.public_ip}</host>
    <port>22</port>
    <credentialsId>ssh-key-frankfurt</credentialsId>
    <launchTimeoutSeconds>60</launchTimeoutSeconds>
    <maxNumRetries>10</maxNumRetries>
    <retryWaitTime>15</retryWaitTime>
    <sshHostKeyVerificationStrategy class="hudson.plugins.sshslaves.verifiers.ManuallyTrustedKeyVerificationStrategy">
      <requireInitialManualTrust>false</requireInitialManualTrust>
    </sshHostKeyVerificationStrategy>
    <tcpNoDelay>true</tcpNoDelay>
  </launcher>
  <label>${var.label_slave_jenkins}</label>
  <nodeProperties/>
</slave>
EOF
EOD
  }

#  provisioner "local-exec" {
#    command = <<EOF
#    aws ec2 wait instance-status-ok --instance-ids ${aws_instance.db.id} --profile default 
#
#  EOF
#  }

}


##### outputs #######

output "public_db_ip" {
  description = "Instance Public IP  of our nginx_task_aws"
    value       = aws_instance.db.public_ip
    }

  
