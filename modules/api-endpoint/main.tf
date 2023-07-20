# ========== Lambda ==========
# ----- Data -----
data "aws_ecr_repository" "ecr_repo" {
  name = var.ecr_repo_name
}

data "aws_ecr_image" "docker_image" {
  repository_name = data.aws_ecr_repository.ecr_repo.name
  most_recent     = true
}

# ----- Function -----
resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.app_name}_${var.path_part}_${var.http_method}"
  role          = var.lambda_role_arn
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.ecr_repo.repository_url}:${data.aws_ecr_image.docker_image.image_tags[0]}"
  timeout       = var.timeout
  image_config {
    command = var.command
  }
}

resource "aws_lambda_permission" "lambda-permission" {
  statement_id  = "Allow${var.api_gateway_name}APIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${data.aws_api_gateway_rest_api.api_gateway.execution_arn}/*"
}

# ========== API Gateway ==========
# ----- Data -----
data "aws_api_gateway_rest_api" "api_gateway" {
  name = var.api_gateway_name
}

# ----- Endpoint -----
resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = data.aws_api_gateway_rest_api.api_gateway.id
  parent_id   = data.aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = var.path_part
}

# ----- Method -----
resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = data.aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = var.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_integration" {
  rest_api_id             = data.aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.api_resource.id
  http_method             = aws_api_gateway_method.api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

# ----- Options Method -----
resource "aws_api_gateway_method" "api_options_method" {
  rest_api_id   = data.aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_options_integration" {
  rest_api_id = data.aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_options_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}

resource "aws_api_gateway_integration_response" "api_options_integration_response" {
  rest_api_id = data.aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_options_method.http_method
  status_code = aws_api_gateway_method_response.api_options_method_response.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = var.allowed_headers != null ? "'Content-Type,${var.allowed_headers}'" : "'Content-Type'",
    "method.response.header.Access-Control-Allow-Methods" = "'${var.http_method},OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'https://${var.url}'",
  }
}

resource "aws_api_gateway_method_response" "api_options_method_response" {
  rest_api_id = data.aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_options_method.http_method
  status_code = 200
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# ========== Cloudwatch ==========
resource "aws_cloudwatch_log_group" "LambdaFunctionLogGroup" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 7
}
