output "api_endpoint_lambda_arns" {
    description = "The ARNs of the Lambda functions from api_endpoint"
    value       = { for method in module.endpoint_methods : method.key => method.lambda_arn }
}