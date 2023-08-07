variable "app_name" {
  type        = string
  description = "The name of the project in kebab-case."
}
variable "ecr_repo" {
  type = object({
    name           = string,
    repository_url = string
  })
  description = "The ECR repository that contains the image for the lambda functions."
}
variable "image_tag" {
  type        = string
  description = "The image tag for the Docker image (the timestamp)."
}
variable "lambda_role_arn" {
  type        = string
  description = "The ARN of the Lambda Role to be attached to the Lambda function."
}
variable "path_part" {
  type        = string
  description = "The URL path to invoke the method."
}

variable "http_method" {
  type        = string
  description = "The HTTP methods for the endpoint."
}
variable "command" {
  type        = list(string)
  description = "The lambda handlers for each method of the endpoint. The syntax is file_name.function_name"
}
variable "timeout" {
  type        = number
  description = "Amount of time your Lambda Function has to run in seconds."
}

variable "api_gateway_name" {
  type        = string
  description = "The name of the API Gateway."
}
variable "api_resource_id" {
  type        = string
  description = "The ID for the API Resource for this endpoint."
}
