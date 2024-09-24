output "api_endpoint_lambda_arns" {
    description = "The ARNs of the Lambda functions from api_endpoint"
    value       = { for method_key, method in module.endpoint_methods : method_key => method.lambda_arn }
}