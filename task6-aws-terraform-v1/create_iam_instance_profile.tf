resource "aws_iam_instance_profile" "s3_read_profile" {
  name  = "s3_onlyread_profile"
  role  = aws_iam_role.ec2_s3_access_role.name
}
