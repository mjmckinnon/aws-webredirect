# This Terraform file:
# - zips up the src/* files
# - creates the lambda function

locals {
  # This is the zip file uploaded to AWS that has the lambda script in it
  lambda_zip_file = "${path.module}/build/web_redirector.zip"
}

data "archive_file" "zip_package" {
  type = "zip"
  source {
    content = file(var.redirection_csv_file)
    filename = "redirections.csv"
  }
  source {
    content = file("${path.module}/src/web_redirector.py")
    filename = "web_redirector.py"
  }
  output_path = local.lambda_zip_file
}

# Create the lambda function
resource "aws_lambda_function" "web_redir_lambda" {
  filename      = local.lambda_zip_file
  function_name = "web_handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "web_redirector.web_handler"
  source_code_hash = filebase64sha256(local.lambda_zip_file)
  runtime = "python3.8"
}

# Setup a permission to invoke which the load balancer will use
resource "aws_lambda_permission" "web_redir" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.web_redir_lambda.arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.web_redir.arn
}
