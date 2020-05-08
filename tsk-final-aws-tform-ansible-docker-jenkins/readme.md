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


```
[root@diplom-ans-aws task-05.05.2020]# ./create.sh
module.vpc.data.aws_availability_zones.available: Refreshing state...
module.vpc.aws_vpc.vpc: Creating...
module.s3.aws_iam_policy.s3_read_policy_db_dev: Creating...
module.s3.aws_iam_role.ec2_s3_access_role_db_dev: Creating...
module.s3.aws_iam_role.ec2_s3_access_role_db_dev: Creation complete after 1s [id=s3_read_role_db_dev]
module.s3.aws_iam_instance_profile.s3_read_profile_db_dev: Creating...
module.s3.aws_iam_policy.s3_read_policy_db_dev: Creation complete after 2s [id=arn:aws:iam::988323654900:policy/S3ReadOnly_db_dev]
module.s3.aws_iam_policy_attachment.attach_s3_read_db_dev: Creating...
module.vpc.aws_vpc.vpc: Creation complete after 3s [id=vpc-08bc1833668f4d9df]
module.vpc.aws_security_group.dev_sg: Creating...
module.vpc.aws_default_route_table.private: Creating...
module.vpc.aws_internet_gateway.internet_gateway: Creating...
module.vpc.aws_security_group.public_sg: Creating...
module.vpc.aws_subnet.public1: Creating...
module.s3.aws_iam_instance_profile.s3_read_profile_db_dev: Creation complete after 2s [id=s3_onlyread_profile_db_dev]
module.s3.aws_iam_policy_attachment.attach_s3_read_db_dev: Creation complete after 2s [id=test_attachment_s3_read_db_dev]
module.vpc.aws_default_route_table.private: Creation complete after 1s [id=rtb-0acb58332b67c93a6]
module.vpc.aws_internet_gateway.internet_gateway: Creation complete after 1s [id=igw-0086acdb174bf3dd5]
module.vpc.aws_route_table.public: Creating...
module.vpc.aws_subnet.public1: Creation complete after 2s [id=subnet-0cc953c32f245c155]
module.vpc.aws_security_group.dev_sg: Creation complete after 3s [id=sg-0310f79287cad1c24]
module.db.aws_instance.db: Creating...
module.test.aws_instance.jenkins: Creating...
module.vpc.aws_security_group.public_sg: Creation complete after 3s [id=sg-0af2c94669eeaa464]
module.vpc.aws_route_table.public: Creation complete after 2s [id=rtb-0010739f1879c6c22]
module.vpc.aws_route_table_association.public1_assoc: Creating...
module.vpc.aws_route_table_association.public1_assoc: Creation complete after 0s [id=rtbassoc-0f7220e197bd6f8b7]
module.db.aws_instance.db: Still creating... [10s elapsed]
module.test.aws_instance.jenkins: Still creating... [10s elapsed]
module.db.aws_instance.db: Still creating... [20s elapsed]
module.test.aws_instance.jenkins: Still creating... [20s elapsed]
module.db.aws_instance.db: Still creating... [30s elapsed]
module.test.aws_instance.jenkins: Still creating... [30s elapsed]
module.db.aws_instance.db: Provisioning with 'local-exec'...
module.db.aws_instance.db (local-exec): Executing: ["/bin/sh" "-c" "cat <<EOF > aws_hosts_db\n[dev]\n54.93.53.7\nEOF\n"]
module.db.aws_instance.db: Provisioning with 'local-exec'...
module.db.aws_instance.db (local-exec): Executing: ["/bin/sh" "-c" "cat <<EOF >  config.xml\n<slave>\n  <name>slave_db_dev</name>\n  <description>slave on Test instance Dev Env</description>\n  <remoteFS>/home/ubuntu/jenkins_slave</remoteFS>\n  <numExecutors>1</numExecutors>\n  <mode>NORMAL</mode>\n  <retentionStrategy class=\"hudson.slaves.RetentionStrategy$Always\"/>\n  <launcher class=\"hudson.plugins.sshslaves.SSHLauncher\" plugin=\"ssh-slaves@1.31.2\">\n    <host>54.93.53.7</host>\n    <port>22</port>\n    <credentialsId>ssh-key-frankfurt</credentialsId>\n    <launchTimeoutSeconds>60</launchTimeoutSeconds>\n    <maxNumRetries>10</maxNumRetries>\n    <retryWaitTime>15</retryWaitTime>\n    <sshHostKeyVerificationStrategy class=\"hudson.plugins.sshslaves.verifiers.ManuallyTrustedKeyVerificationStrategy\">\n      <requireInitialManualTrust>false</requireInitialManualTrust>\n    </sshHostKeyVerificationStrategy>\n    <tcpNoDelay>true</tcpNoDelay>\n  </launcher>\n  <label>db_dev</label>\n  <nodeProperties/>\n</slave>\nEOF\n"]
module.db.aws_instance.db: Creation complete after 32s [id=i-0135ad3a0240fa2ed]
module.test.aws_instance.jenkins: Provisioning with 'local-exec'...
module.test.aws_instance.jenkins (local-exec): Executing: ["/bin/sh" "-c" "cat <<EOF > aws_hosts_jenkins\n[jenkins]\n3.122.56.152\nEOF\n"]
module.test.aws_instance.jenkins: Provisioning with 'local-exec'...
module.test.aws_instance.jenkins (local-exec): Executing: ["/bin/sh" "-c" "cat <<EOF > ip_jenkins\n3.122.56.152\nEOF\n"]
module.test.aws_instance.jenkins: Creation complete after 38s [id=i-08b3091145caf8ba2]
module.test.aws_instance.test: Creating...
module.test.aws_instance.test: Still creating... [10s elapsed]
module.test.aws_instance.test: Still creating... [20s elapsed]
module.test.aws_instance.test: Provisioning with 'local-exec'...
module.test.aws_instance.test (local-exec): Executing: ["/bin/sh" "-c" "cat <<EOF > aws_hosts_test\n[test]\n18.184.91.77\nEOF\n"]
module.test.aws_instance.test: Provisioning with 'local-exec'...
module.test.aws_instance.test (local-exec): Executing: ["/bin/sh" "-c" "cat <<EOF >  config.xml.test\n<slave>\n  <name>slave_test</name>\n  <description>slave on Test instance Dev Env</description>\n  <remoteFS>/home/ubuntu/jenkins_slave</remoteFS>\n  <numExecutors>1</numExecutors>\n  <mode>NORMAL</mode>\n  <retentionStrategy class=\"hudson.slaves.RetentionStrategy$Always\"/>\n  <launcher class=\"hudson.plugins.sshslaves.SSHLauncher\" plugin=\"ssh-slaves@1.31.2\">\n    <host>18.184.91.77</host>\n    <port>22</port>\n    <credentialsId>ssh-key-frankfurt</credentialsId>\n    <launchTimeoutSeconds>60</launchTimeoutSeconds>\n    <maxNumRetries>10</maxNumRetries>\n    <retryWaitTime>15</retryWaitTime>\n    <sshHostKeyVerificationStrategy class=\"hudson.plugins.sshslaves.verifiers.ManuallyTrustedKeyVerificationStrategy\">\n      <requireInitialManualTrust>false</requireInitialManualTrust>\n    </sshHostKeyVerificationStrategy>\n    <tcpNoDelay>true</tcpNoDelay>\n  </launcher>\n  <label>test</label>\n  <nodeProperties/>\n</slave>\nEOF\n"]
module.test.aws_instance.test: Creation complete after 23s [id=i-06f0036b8a4de216d]

Warning: Quoted type constraints are deprecated

  on main.tf line 5, in variable "cidrs_project":
   5: variable   "cidrs_project"                      {  type = "map"   }

Terraform 0.11 and earlier required type constraints to be given in quotes,
but that form is now deprecated and will be removed in a future version of
Terraform. To silence this warning, remove the quotes around "map" and write
map(string) instead to explicitly indicate that the map elements are strings.


Apply complete! Resources: 15 added, 0 changed, 0 destroyed.
Releasing state lock. This may take a few moments...

Outputs:

public_ip_dev_db = 54.93.53.7
public_ip_jenkins = 3.122.56.152
public_ip_test = 18.184.91.77
module.vpc.data.aws_availability_zones.available: Refreshing state...
module.s3_prod.aws_iam_role.ec2_s3_access_role_db_prod: Creating...
module.vpc.aws_vpc.vpc: Creating...
module.s3_prod.aws_iam_policy.s3_read_policy_db_prod: Creating...
module.s3_prod.aws_iam_role.ec2_s3_access_role_db_prod: Creation complete after 1s [id=s3_read_role_db_prod]
module.s3_prod.aws_iam_instance_profile.s3_read_profile_db_prod: Creating...
module.s3_prod.aws_iam_policy.s3_read_policy_db_prod: Creation complete after 2s [id=arn:aws:iam::988323654900:policy/S3ReadOnly_db_prod]
module.s3_prod.aws_iam_policy_attachment.attach_s3_read_db_prod: Creating...
module.s3_prod.aws_iam_instance_profile.s3_read_profile_db_prod: Creation complete after 2s [id=s3_onlyread_profile_db_prod]
module.vpc.aws_vpc.vpc: Creation complete after 3s [id=vpc-0e6a51cf95e47b1c2]
module.vpc.aws_security_group.dev_sg: Creating...
module.vpc.aws_security_group.public_sg: Creating...
module.vpc.aws_internet_gateway.internet_gateway: Creating...
module.vpc.aws_default_route_table.private: Creating...
module.vpc.aws_subnet.public1: Creating...
module.s3_prod.aws_iam_policy_attachment.attach_s3_read_db_prod: Creation complete after 1s [id=test_attachment_s3_read_db_prod]
module.vpc.aws_default_route_table.private: Creation complete after 1s [id=rtb-02a1c25ecfdb829a3]
module.vpc.aws_internet_gateway.internet_gateway: Creation complete after 1s [id=igw-068bec637c00daf0a]
module.vpc.aws_route_table.public: Creating...
module.vpc.aws_subnet.public1: Creation complete after 1s [id=subnet-0d52738e29d3c9d4e]
module.vpc.aws_security_group.dev_sg: Creation complete after 2s [id=sg-0c935fe4771cf0fa7]
module.vpc.aws_security_group.public_sg: Creation complete after 2s [id=sg-0d05132d72c59af16]
module.db.aws_instance.db: Creating...
module.vpc.aws_route_table.public: Creation complete after 2s [id=rtb-06beb4a8a52698efa]
module.vpc.aws_route_table_association.public1_assoc: Creating...
module.vpc.aws_route_table_association.public1_assoc: Creation complete after 0s [id=rtbassoc-01bdc4d0e76bc9e6a]
module.db.aws_instance.db: Still creating... [10s elapsed]
module.db.aws_instance.db: Still creating... [20s elapsed]
module.db.aws_instance.db: Provisioning with 'local-exec'...
module.db.aws_instance.db (local-exec): Executing: ["/bin/sh" "-c" "cat <<EOF > aws_hosts_db\n[dev]\n18.185.56.51\nEOF\n"]
module.db.aws_instance.db: Provisioning with 'local-exec'...
module.db.aws_instance.db (local-exec): Executing: ["/bin/sh" "-c" "cat <<EOF >  config.xml\n<slave>\n  <name>prod_slave</name>\n  <description>slave on Test instance Dev Env</description>\n  <remoteFS>/home/ubuntu/jenkins_slave</remoteFS>\n  <numExecutors>1</numExecutors>\n  <mode>NORMAL</mode>\n  <retentionStrategy class=\"hudson.slaves.RetentionStrategy$Always\"/>\n  <launcher class=\"hudson.plugins.sshslaves.SSHLauncher\" plugin=\"ssh-slaves@1.31.2\">\n    <host>18.185.56.51</host>\n    <port>22</port>\n    <credentialsId>ssh-key-frankfurt</credentialsId>\n    <launchTimeoutSeconds>60</launchTimeoutSeconds>\n    <maxNumRetries>10</maxNumRetries>\n    <retryWaitTime>15</retryWaitTime>\n    <sshHostKeyVerificationStrategy class=\"hudson.plugins.sshslaves.verifiers.ManuallyTrustedKeyVerificationStrategy\">\n      <requireInitialManualTrust>false</requireInitialManualTrust>\n    </sshHostKeyVerificationStrategy>\n    <tcpNoDelay>true</tcpNoDelay>\n  </launcher>\n  <label>db_prod</label>\n  <nodeProperties/>\n</slave>\nEOF\n"]
module.db.aws_instance.db: Creation complete after 29s [id=i-0c7ac655a0b0f0767]

Warning: Quoted type constraints are deprecated

  on main.tf line 5, in variable "cidrs_project":
   5: variable   "cidrs_project"                      {  type = "map"   }

Terraform 0.11 and earlier required type constraints to be given in quotes,
but that form is now deprecated and will be removed in a future version of
Terraform. To silence this warning, remove the quotes around "map" and write
map(string) instead to explicitly indicate that the map elements are strings.


Apply complete! Resources: 13 added, 0 changed, 0 destroyed.
Releasing state lock. This may take a few moments...

Outputs:

public_ip_db_prod = 18.185.56.51

PLAY [apply roles for host with "jenkins in docker"] *************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************
ok: [3.122.56.152]

TASK [docker : Update all packages] ******************************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : Install aptitude using apt] ***********************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : Install required system packages] *****************************************************************************************************************************************************
changed: [3.122.56.152] => (item=apt-transport-https)
ok: [3.122.56.152] => (item=ca-certificates)
ok: [3.122.56.152] => (item=curl)
ok: [3.122.56.152] => (item=software-properties-common)
changed: [3.122.56.152] => (item=python3-pip)
changed: [3.122.56.152] => (item=virtualenv)
ok: [3.122.56.152] => (item=python3-setuptools)

TASK [docker : Add Docker GPG apt Key] ***************************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : Add Docker Repository] ****************************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : Update apt and install docker-ce] *****************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : Install Docker Module for Python] *****************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : nstall PyGithub] **********************************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : Ensure jenkins directory on docker host] **********************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : copy from S3 bucet jencins archive] ***************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : copy xml config prod_slave] ***********************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : copy xml config slave_test] ***********************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : copy xml config slave_db_dev] *********************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : Pull the latest official jenkins docker image] ****************************************************************************************************************************************
[WARNING]: The value of the "source" option was determined to be "pull". Please set the "source" option explicitly. Autodetection will be removed in Ansible 2.12.

changed: [3.122.56.152]

TASK [docker : Ensure Jenkins server started] ********************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : Copy systemd service script to start and stop the jenkins container] ******************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : Reload systemctl] *********************************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : create a new webhook that triggers on push] *******************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : check docker] *************************************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : debug] ********************************************************************************************************************************************************************************
ok: [3.122.56.152] => {
    "docker_info": {
        "changed": true,
        "cmd": "docker version",
        "delta": "0:00:00.132184",
        "end": "2020-05-08 10:08:21.303844",
        "failed": false,
        "rc": 0,
        "start": "2020-05-08 10:08:21.171660",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "Client: Docker Engine - Community\n Version:           19.03.8\n API version:       1.40\n Go version:        go1.12.17\n Git commit:        afacb8b7f0\n Built:             Wed Mar 11 01:25:46 2020\n OS/Arch:           linux/amd64\n Experimental:      false\n\nServer: Docker Engine - Community\n Engine:\n  Version:          19.03.8\n  API version:      1.40 (minimum version 1.12)\n  Go version:       go1.12.17\n  Git commit:       afacb8b7f0\n  Built:            Wed Mar 11 01:24:19 2020\n  OS/Arch:          linux/amd64\n  Experimental:     false\n containerd:\n  Version:          1.2.13\n  GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429\n runc:\n  Version:          1.0.0-rc10\n  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd\n docker-init:\n  Version:          0.18.0\n  GitCommit:        fec3683",
        "stdout_lines": [
            "Client: Docker Engine - Community",
            " Version:           19.03.8",
            " API version:       1.40",
            " Go version:        go1.12.17",
            " Git commit:        afacb8b7f0",
            " Built:             Wed Mar 11 01:25:46 2020",
            " OS/Arch:           linux/amd64",
            " Experimental:      false",
            "",
            "Server: Docker Engine - Community",
            " Engine:",
            "  Version:          19.03.8",
            "  API version:      1.40 (minimum version 1.12)",
            "  Go version:       go1.12.17",
            "  Git commit:       afacb8b7f0",
            "  Built:            Wed Mar 11 01:24:19 2020",
            "  OS/Arch:          linux/amd64",
            "  Experimental:     false",
            " containerd:",
            "  Version:          1.2.13",
            "  GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429",
            " runc:",
            "  Version:          1.0.0-rc10",
            "  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd",
            " docker-init:",
            "  Version:          0.18.0",
            "  GitCommit:        fec3683"
        ]
    }
}

TASK [docker : check runing container jenkins] *******************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : debug] ********************************************************************************************************************************************************************************
ok: [3.122.56.152] => {
    "jenkins_status": {
        "changed": true,
        "cmd": "docker ps -a",
        "delta": "0:00:00.119247",
        "end": "2020-05-08 10:08:23.406909",
        "failed": false,
        "rc": 0,
        "start": "2020-05-08 10:08:23.287662",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                                              NAMES\nc95418a1d2eb        jenkinsci/blueocean   \"/sbin/tini -- /usr/…\"   18 seconds ago      Up 16 seconds       0.0.0.0:50000->50000/tcp, 0.0.0.0:8081->8080/tcp   jenkins-server",
        "stdout_lines": [
            "CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                                              NAMES",
            "c95418a1d2eb        jenkinsci/blueocean   \"/sbin/tini -- /usr/…\"   18 seconds ago      Up 16 seconds       0.0.0.0:50000->50000/tcp, 0.0.0.0:8081->8080/tcp   jenkins-server"
        ]
    }
}

TASK [docker : check opened ports] *******************************************************************************************************************************************************************
changed: [3.122.56.152]

TASK [docker : debug] ********************************************************************************************************************************************************************************
ok: [3.122.56.152] => {
    "open_ports": {
        "changed": true,
        "cmd": "netstat -ltpn",
        "delta": "0:00:00.021251",
        "end": "2020-05-08 10:08:25.378194",
        "failed": false,
        "rc": 0,
        "start": "2020-05-08 10:08:25.356943",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "Active Internet connections (only servers)\nProto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    \ntcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      601/systemd-resolve \ntcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      895/sshd            \ntcp6       0      0 :::50000                :::*                    LISTEN      25490/docker-proxy  \ntcp6       0      0 :::8081                 :::*                    LISTEN      25503/docker-proxy  \ntcp6       0      0 :::22                   :::*                    LISTEN      895/sshd            ",
        "stdout_lines": [
            "Active Internet connections (only servers)",
            "Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    ",
            "tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      601/systemd-resolve ",
            "tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      895/sshd            ",
            "tcp6       0      0 :::50000                :::*                    LISTEN      25490/docker-proxy  ",
            "tcp6       0      0 :::8081                 :::*                    LISTEN      25503/docker-proxy  ",
            "tcp6       0      0 :::22                   :::*                    LISTEN      895/sshd            "
        ]
    }
}

PLAY RECAP *******************************************************************************************************************************************************************************************
3.122.56.152               : ok=25   changed=21   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```


