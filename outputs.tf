output "lambda_api_lambda_arns" {
    description = "The ARNs of the Lambda functions from all api_endpoint instances"
    value       = { for api in module.lambda_api : api.key => api.api_endpoint_lambda_arns }
}