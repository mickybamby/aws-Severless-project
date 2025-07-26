#create dynamoDB to store user data
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = var.name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  
  attribute {
    name = "${var.hash_key}"
    type = "S"
  }

  tags = {
    Name        = var.name
    Environment = var.Environment
  }
}

#create lamba function
# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {    // Lambda execution role, that basically establish the trust identity between lamda and the role
  name               = var.name_role
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# IAM policy for Lambda execution
data "aws_iam_policy_document" "lambda_policy" {
    statement {
    sid       = "DDBAndDAXFullAccess"
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "example" {
  name   = var.name_policy_lamba
  policy = data.aws_iam_policy_document.lambda_policy.json
}
# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.example.arn
}

# Package the Lambda function code
data "archive_file" "example" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/lambda/function.zip"
}

# Lambda function to test and deploy the python
resource "aws_lambda_function" "example" {
  filename         = data.archive_file.example.output_path
  function_name    = var.function_name
  role             = aws_iam_role.example.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.example.output_base64sha256
  runtime = var.runtime
}

##############################################
#creating and API Gateway
#############################################

