module "aws-serverless-workshop" {
  source            = "./module/aws-serverless-workshop"
  name              = "serverless_workshop_intro"
  billing_mode      = "PAY_PER_REQUEST"
  hash_key          = "_id"
  Name              = "order-users"
  Environment       = "Dev"
  function_name     = "m1-add-sample-data"
  name_role         = "m1-add-sample-data-execution-role"
  runtime           = "python3.12"
  name_policy_lamba = "m1-add-sample-data-execution-policy"
}