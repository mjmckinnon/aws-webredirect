# For the S3 bucket policy we need the current AWS account ID
data "aws_caller_identity" "current" {}

# An S3 bucket for storing logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "web-redir-log-bucket"
  acl    = "log-delivery-write"
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
