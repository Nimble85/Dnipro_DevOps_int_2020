

$ aws cloudformation create-stack --template-body file://templates/single-instance.yml --stack-name single-instance --parameters ParameterKey=KeyName,ParameterValue=SOME-EXISTING-KEY-PAIR ParameterKey=InstanceType,ParameterValue=t2.micro