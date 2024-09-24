output "lambda_function_arn" {
    value = { for key, lambda in aws_lambda_function.lambda_function : key => lambda.arn }
}