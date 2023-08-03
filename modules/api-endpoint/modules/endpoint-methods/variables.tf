variable "http_method" {
  type        = list(string)
  description = "The HTTP methods for the endpoint."
}
variable "command" {
  type        = list(list(string))
  description = "The handlers for each method of the lambda function. The syntax is file_name.function_name"
}
variable "timeout" {
  type        = list(number)
  description = "Amount of time your Lambda Function has to run in seconds."
}
