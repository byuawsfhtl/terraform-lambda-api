variable "project_name" {
  type        = string
  description = "The name of the project in TitleCase."
}
variable "app_name" {
  type        = string
  description = "The name of the project in kebab-case."
}
variable "url" {
  type        = string
  description = "The url of the application. Ex: projectname.rll.byu.edu"
}
variable "ecr_repo_name" {
  type        = string
  description = "The name of the ECR repository that contains the image for the lambda functions."
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
  description = "The HTTP method for the endpoint."
}
variable "command" {
  type        = list(string)
  description = "The handler for the lambda function. The syntax is file_name.function_name"
}
variable "allowed_headers" {
  type        = string
  description = "The custom headers the endpoint should allow. Provided as a string with each header key separated by a comma."
}
variable "timeout" {
  type        = number
  description = "Amount of time your Lambda Function has to run in seconds."
}

variable "api_gateway_name" {
  type        = string
  description = "The name of the API Gateway."
}

