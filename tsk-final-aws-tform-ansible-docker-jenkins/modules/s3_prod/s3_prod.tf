resource "aws_iam_role" "ec2_s3_access_role_db_prod" {
  name               = "s3_read_role_db_prod"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ec2.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF

}


resource "aws_iam_instance_profile" "s3_read_profile_db_prod" {
  name  = "s3_onlyread_profile_db_prod"
  role  = aws_iam_role.ec2_s3_access_role_db_prod.name
}
resource "aws_iam_policy" "s3_read_policy_db_prod" {
  name        = "S3ReadOnly_db_prod"
  description = "S3ReadOnly policy_db_prod"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
    {
       "Effect": "Allow",
       "Action": [
          "s3:Get*",
          "s3:List*"
       ],
           "Resource": "*"
        }
    ]

}
EOF
}

resource "aws_iam_policy_attachment" "attach_s3_read_db_prod" {
  name       = "test_attachment_s3_read_db_prod"
  roles      =["${aws_iam_role.ec2_s3_access_role_db_prod.name}"]
  policy_arn = aws_iam_policy.s3_read_policy_db_prod.arn
}





#########
output "aws_iam_instance_profile_s3_read_profile_db_prod_name" {
  value = aws_iam_instance_profile.s3_read_profile_db_prod.name

}

