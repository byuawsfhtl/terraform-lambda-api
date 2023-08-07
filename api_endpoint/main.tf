locals {
  method_map = {
    for def in var.method_definitions : "${var.app_name}_${var.path_part}_${def.http_method}" => {
      http_method = def.http_method
      command     = def.command
      timeout     = def.timeout
    }
  }
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

# ----- Methods -----
module "endpoint_methods" {
  source = "./endpoint_methods/"

  for_each = local.method_map

  app_name        = var.app_name
  ecr_repo        = var.ecr_repo
  image_tag       = var.image_tag
  lambda_role_arn = var.lambda_role.arn
  path_part       = var.path_part

  http_method = each.value.http_method
  command     = each.value.command
  timeout     = each.value.timeout

  api_gateway_name = var.api_gateway.name
  api_resource_id  = aws_api_gateway_resource.api_resource.id
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
