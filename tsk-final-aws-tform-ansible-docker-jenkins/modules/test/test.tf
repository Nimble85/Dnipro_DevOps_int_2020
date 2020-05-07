variable "ami"                             {}
variable "size_instance_dev"               {}
variable "keypair"                         {}
variable "vpc_security_group_ids_instance" {}
variable "subnet_id"                       {}
variable "env_instance"                    {}
variable "subnet_id_instance"              {}
variable  "role"                            {}

resource "aws_instance" "test" {
  ami                         = var.ami
  instance_type               = var.size_instance_dev
  vpc_security_group_ids      = [var.vpc_security_group_ids_instance]
#  iam_instance_profile        = aws_iam_instance_profile.s3_read_profile_db_dev.name
  iam_instance_profile        = var.role
  associate_public_ip_address = true
  key_name                    = var.keypair
  subnet_id                   = var.subnet_id_instance
  depends_on                  = [aws_instance.jenkins]
  user_data                   = file("../files/user_data_test.sh")
#  associate_public_ip_address = true
  tags = {
    Name    = "Test_dev"
    Env     =  var.env_instance
    Owner   = "Kozulenko Volodymyr"
  }

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > aws_hosts_test
[test]
${aws_instance.test.public_ip}
EOF
EOD
  }

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >  config.xml.test
<slave>
  <name>slave_test</name>
  <description>slave on Test instance Dev Env</description>
  <remoteFS>/home/ubuntu/jenkins_slave</remoteFS>
  <numExecutors>1</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.31.2">
    <host>${aws_instance.test.public_ip}</host>
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
  <label>test</label>
  <nodeProperties/>
</slave>
EOF
EOD
  }
                                                              
#  provisioner "local-exec" {
#    command = <<EOF
#    aws ec2 wait instance-status-ok --instance-ids ${aws_instance.test.id} --profile default
#  EOF
#  }

}


resource "aws_instance" "jenkins" {
  ami                         = var.ami
  instance_type               = var.size_instance_dev
  vpc_security_group_ids      = [var.vpc_security_group_ids_instance]
  iam_instance_profile        = var.role 
  associate_public_ip_address = true
  key_name                    = var.keypair
  subnet_id                   = var.subnet_id_instance
  user_data                   = file("../files/user_data_jenkins.sh")
  tags = {
    Name    = "Jenkins_dev"
    Env     =  var.env_instance
    Owner   = "Kozulenko Volodymyr"
  }

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > aws_hosts_jenkins
[jenkins]
${aws_instance.jenkins.public_ip}
EOF
EOD
  }
#  provisioner "local-exec" {
#    command = <<EOF
#    aws ec2 wait instance-status-ok --instance-ids ${aws_instance.jenkins.id} --profile default
#    
#  EOF
#  }

#  provisioner "local-exec" {
#    command = <<EOF
#    aws ec2 wait instance-status-ok --instance-ids ${aws_instance.jenkins.id} --profile default  &&
#    ansible-playbook -vvv --private-key ~/.ssh/jenkins.pem  -i aws_hosts_jenkins ansible/bootstrap_jenkins.yml
#
#  EOF
#  }

}

output "public_test_ip" {
  description = "Instance Public IP  of our nginx_task_aws"
    value     = aws_instance.test.public_ip
    }

output "public_jenkins_ip" {
  description = "Instance Public IP  of our nginx_task_aws"
    value     = aws_instance.jenkins.public_ip
    }


