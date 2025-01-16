output "lambda_api_lambda_arns" {
  description = "The ARNs of the Lambda functions from all api_endpoint instances"
  value       = { for api_key, api in module.api_endpoint : api_key => api.api_endpoint_lambda_arns }
}