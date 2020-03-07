resource "aws_iam_policy" "s3_read_policy" {
  name        = "S3ReadOnly"
  description = "S3ReadOnly policy"
  policy      = file("policys3bucket.json")
}
