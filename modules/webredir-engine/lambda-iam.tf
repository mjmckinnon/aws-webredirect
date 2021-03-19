# Creates an IAM role with the correct policy for actions needed

# Lambda policy (check the JSON file for detail)
resource "aws_iam_role_policy" "lambda_policy" {
  name = "webredir-lambda-policy"
  role = aws_iam_role.lambda_role.id
  policy = templatefile("${path.module}/templates/lambda-policy.tmpl", {})
}

# Assume role policy (check the JSON file for detail)
resource "aws_iam_role" "lambda_role" {
  name = "webredir-lambda-role"
  assume_role_policy = templatefile("${path.module}/templates/lambda-assume-policy.tmpl", {})
}
