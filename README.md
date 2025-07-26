# aws-Severless-project

1. Navigate to the Lambda function 'm1-add-sample-data' in the AWS Lambda console

2. Click on the 'Code' tab

3. In the code editor, locate or create a file named 'index.py'

4. In 'index.py', ensure there's a function named 'handler'. For example:
   ```python
   def handler(event, context):
       # Your function logic here
       return {
           'statusCode': 200,
           'body': 'Function executed successfully'
       }
   ```

5. If the function name is different, or if you prefer a different name, you can change the handler configuration:
   - Click on the 'Configuration' tab
   - Select 'General configuration' from the left sidebar
   - Click 'Edit'
   - Update the 'Handler' field to match your function name (e.g., 'index.handler')
   - Click 'Save'

6. After making changes, click 'Deploy' to save and deploy your code

7. Test the function again to verify the error has been resolved

#create role for lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "policy" { 
  name        = "test_policy"
  path        = "/"
  description = "My test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:BatchGetItem",
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:ListTables",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:DescribeReservedCapacity",
        "dynamodb:DescribeReservedCapacityOfferings"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

#create Gateway REST API
resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "MyDemoAPI"
  description = "This is my API for demonstration purposes"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "MyDemoFunction"
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.MyDemoAPI.execution_arn}/*"
}