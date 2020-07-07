resource "aws_iam_role" "myRdsFunction-role" {
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "lambda.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    force_detach_policies = false
    name                  = var.lambda_role_name
    path                  = "/service-role/"
}

data "aws_iam_policy" "AWSLambdaVPCAccessExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda-vpc-attach" {
    policy_arn = data.aws_iam_policy.AWSLambdaVPCAccessExecutionRole.arn
    role       = aws_iam_role.myRdsFunction-role.name
}

resource "aws_lambda_function" "myRdsFunction" {
    function_name                  = "myRdsFunction"
    handler                        = "index.handler"
    runtime                        = "nodejs12.x"
    role                           = aws_iam_role.myRdsFunction-role.arn
    source_code_hash               = var.lambda_source_code_hash
    timeout                        = 30

    environment {
        variables = {
            "db"       = var.db_name
            "endpoint" = var.db_endpoint
            "password" = var.db_password
            "user"     = var.db_username
        }
    }

    vpc_config {
        security_group_ids = [
            aws_security_group.default-vpc-sg.id,
        ]
        subnet_ids         = [
            aws_subnet.default-subnet-2a.id,
            aws_subnet.default-subnet-2b.id,
            aws_subnet.default-subnet-2c.id,
        ]
    }
}

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
    uri                     = aws_lambda_function.myRdsFunction.invoke_arn
}