resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "s3_read_role"
  assume_role_policy = file("assumerolepolicy.json")
}
