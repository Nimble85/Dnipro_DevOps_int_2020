# Task 8
```
1. Create a bucket and add a file to the bucket. 
2. Create an IAM user. 
3. Allow the IAM user read/write access to the file in the bucket. 
4. Create an IAM group 
5. Add the user to the group 
6. Add a policy to the group 
7. Create and use a role.
```
## Solution
### 1. Create a bucket and add a file to the bucket.* 
#### aws s3 mb s3://bucket-task8
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic1.png) 

#### aws s3 ls
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic2.png) 
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic3.png) 

#### aws s3 cp testfile.txt  s3://bucket-task8
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic6.png) 
#### aws s3 ls s3://bucket-task8
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic7.png) 
### 2. Create an IAM user. 
#### aws iam create-user --user-name Task8
```
{
    "User": {
        "UserName": "Task8",
        "Path": "/",
        "CreateDate": "2020-03-18T10:20:37Z",
        "UserId": "AIDA6MHFOFT2NFJ77WFVJ",
        "Arn": "arn:aws:iam::988323654900:user/Task8"
    }
}
```
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic4.png) 

#### aws iam list-users
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic5.png)

### 3. Allow the IAM user read/write access to the file in the bucket.
task8-testfile-policy.json
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["arn:aws:s3:::bucket-task8"]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": ["arn:aws:s3:::bucket-task8/testfile.txt"]
        }
    ]
}
```

#### aws iam create-policy --policy-name task8-testfile-policy --policy-document file://task8-testfile-policy.json
```
{
    "Policy": {
        "PolicyName": "task8-testfile-policy",
        "PermissionsBoundaryUsageCount": 0,
        "CreateDate": "2020-03-18T12:00:22Z",
        "AttachmentCount": 0,
        "IsAttachable": true,
        "PolicyId": "ANPA6MHFOFT2OOZYB4M6C",
        "DefaultVersionId": "v1",
        "Path": "/",
        "Arn": "arn:aws:iam::988323654900:policy/task8-testfile-policy",
        "UpdateDate": "2020-03-18T12:00:22Z"
    }
}
```
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic8.png)

#### aws iam attach-user-policy --policy-arn arn:aws:iam::988323654900:policy/task8-testfile-policy --user-name Task8

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic9.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic10.png)

### 4. Create an IAM group
#### aws iam create-group --group-name group-task8
```
{
    "Group": {
        "Path": "/",
        "CreateDate": "2020-03-18T12:15:09Z",
        "GroupId": "AGPA6MHFOFT2DIY3BEB4P",
        "Arn": "arn:aws:iam::988323654900:group/group-task8",
        "GroupName": "group-task8"
    }
}
```
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic11.png)

### 5. Add the user to the group
#### aws iam add-user-to-group --user-name Task8 --group-name group-task8
#### aws iam get-group --group-name group-task8
```
{
    "Group": {
        "Path": "/",
        "CreateDate": "2020-03-18T12:15:09Z",
        "GroupId": "AGPA6MHFOFT2DIY3BEB4P",
        "Arn": "arn:aws:iam::988323654900:group/group-task8",
        "GroupName": "group-task8"
    },
    "Users": [
        {
            "UserName": "Task8",
            "Path": "/",
            "CreateDate": "2020-03-18T10:20:37Z",
            "UserId": "AIDA6MHFOFT2NFJ77WFVJ",
            "Arn": "arn:aws:iam::988323654900:user/Task8"
        }
    ]
}
```
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic12.png)

### 6. Add a policy to the group
#### aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess --group-name  group-task8
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic13.png)


### 7. Create and use a role.

Test-Role-Trust-Policy.json
```
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Principal": { "AWS": "arn:aws:iam::988323654900:user/Task8" },
        "Action": "sts:AssumeRole"
    }
}
```
#### aws iam create-role --role-name Test-Role --assume-role-policy-document file://example-role-trust-policy.json
```
{
    "Role": {
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": {
                "Action": "sts:AssumeRole",
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::988323654900:user/Task8"
                }
            }
        },
        "RoleId": "AROA6MHFOFT2BRBK4FLEC",
        "CreateDate": "2020-03-18T12:42:59Z",
        "RoleName": "example-role",
        "Path": "/",
        "Arn": "arn:aws:iam::988323654900:role/example-role"
    }
}
```
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic14.png)

#### aws iam attach-role-policy --role-name example-role --policy-arn "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"

#### aws iam list-attached-role-policies --role-name example-role
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task8-aws-cli/screenshot/pic15.png)

