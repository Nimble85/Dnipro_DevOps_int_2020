# TASK
```
Create a yaml file which describes AWS stack to deploy (could be taken from Terraform task)
Acceptance Criteria:
1. Stack has at least one parameter with default value, with "Allowed values" option and Output.
2. Task accepting format - Demo session starting with code review
3. Your stack is able to be deployed and deleted successfully
4. We can see all activities in AWS CF Console in real time in parallel
5. We can check the Output value(s) in AWS Console
6. English language is preferable (but not mandatory)
```

# Solution
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task11-AWS-CloudFormation/screenshot/pic1.png)


# Deploy template yia awscli

### aws cloudformation deploy --template-file ./deploy-lamp.yaml --stack-name LAMP-Stack

### cloudformation delete-stack --stack-name LAMP-Stack


![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task11-AWS-CloudFormation/screenshot/pic3.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task11-AWS-CloudFormation/screenshot/pic4.png)