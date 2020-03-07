resource "aws_iam_policy_attachment" "attach_s3_read" {
  name       = "test_attachment_s3_read"
  roles      =["${aws_iam_role.ec2_s3_access_role.name}"]
  policy_arn = aws_iam_policy.s3_read_policy.arn
}
