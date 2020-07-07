resource "aws_api_gateway_rest_api" "MyRdsFunction-API" {
    name                     = "myRdsFunction-API"
    description              = "Created by AWS Lambda"
}

resource "aws_api_gateway_resource" "MyRdsFunction-API-Resource" {
    rest_api_id = aws_api_gateway_rest_api.MyRdsFunction-API.id
    parent_id   = aws_api_gateway_rest_api.MyRdsFunction-API.root_resource_id
    path_part   = "myRdsFunction"
}

resource "aws_api_gateway_method" "get" {
    rest_api_id   = aws_api_gateway_rest_api.MyRdsFunction-API.id
    resource_id   = aws_api_gateway_resource.MyRdsFunction-API-Resource.id
    http_method   = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "MyRdsFunction-Integration" {
    rest_api_id             = aws_api_gateway_rest_api.MyRdsFunction-API.id
    resource_id             = aws_api_gateway_resource.MyRdsFunction-API-Resource.id
    http_method             = aws_api_gateway_method.get.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    content_handling        = "CONVERT_TO_TEXT"
    uri                     = var.lambda_invocation_arn
}

/*
resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_name"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "exports.test"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = "${filebase64sha256("lambda_function_payload.zip")}"

  runtime = "nodejs12.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
*/
