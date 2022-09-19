# For the S3 bucket policy we need the current AWS account ID
data "aws_caller_identity" "current" {}

# An S3 bucket for storing logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "web-redir-log-bucket"
}

# ACL for S3 log bucket
resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  # TODO check if the below is correct, according to AWS docs
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl
  acl = "log-delivery-write"
}

# Apply policy to the S3 bucket
resource "aws_s3_bucket_policy" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.bucket
  policy = templatefile("${path.module}/templates/log-bucket-s3-policy.tmpl",
  {
    bucket_name = aws_s3_bucket.log_bucket.bucket,
    prefix = "alb-logs",
    account_id = data.aws_caller_identity.current.account_id
  }
  )
}
