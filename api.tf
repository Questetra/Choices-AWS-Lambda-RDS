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

data "archive_file" "lambda-src-zip" {
  type        = "zip"
  source_dir = "lambda-src"
  output_path = "lambda/myRdsFunction.zip"
}

resource "aws_lambda_function" "myRdsFunction" {
    function_name                  = var.lambda_function_name
    handler                        = "index.handler"
    runtime                        = "nodejs12.x"
    role                           = aws_iam_role.myRdsFunction-role.arn
    source_code_hash               = filebase64sha256(data.archive_file.lambda-src-zip.output_path)
    timeout                        = 30

    environment {
        variables = {
            "db"       = var.db_name
            "endpoint" = aws_rds_cluster.sample-database-1.reader_endpoint // RDS Proxy を使用する場合は変更する
            "password" = var.db_password
            "user"     = var.db_username
            "table"    = var.db_table
        }
    }

    vpc_config {
        security_group_ids = [
            aws_security_group.default-vpc-sg.id,
        ]
        subnet_ids         = [
            aws_subnet.subnet-2a.id,
            aws_subnet.subnet-2b.id,
            aws_subnet.subnet-2c.id,
        ]
    }
}

resource "aws_api_gateway_rest_api" "MyRdsFunction-API" {
    name                     = var.api_name
    description              = "Created by AWS Lambda"
}

resource "aws_api_gateway_resource" "MyRdsFunction-API-Resource" {
    rest_api_id = aws_api_gateway_rest_api.MyRdsFunction-API.id
    parent_id   = aws_api_gateway_rest_api.MyRdsFunction-API.root_resource_id
    path_part   = var.api_path
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

// In case of deploying the API to default stage:
data "aws_region" "current" {}

output "api_url" {
    value = "https://${aws_api_gateway_rest_api.MyRdsFunction-API.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/default/${aws_api_gateway_resource.MyRdsFunction-API-Resource.path_part}"
}

// In order to deploy the API to a certain stage:
/*
// FYI: aws_api_gateway_deployment does not support import command.
resource "aws_api_gateway_deployment" "MyRdsFunction-Deployment" {
  depends_on = [aws_api_gateway_integration.MyRdsFunction-Integration]

  rest_api_id = aws_api_gateway_rest_api.MyRdsFunction-API.id
  stage_name  = var.api_stage

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "default" {
    stage_name    = var.api_stage
    rest_api_id   = aws_api_gateway_rest_api.MyRdsFunction-API.id
    deployment_id = aws_api_gateway_deployment.MyRdsFunction-Deployment.id
}

output "api_url" {
    value =  "${aws_api_gateway_stage.default.invoke_url}/${aws_api_gateway_resource.MyRdsFunction-API-Resource.path_part}"
}
*/