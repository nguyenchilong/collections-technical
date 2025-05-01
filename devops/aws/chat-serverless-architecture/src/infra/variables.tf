variable "region" {
  default = "us-east-1"
}


variable "apigateway_log_path" {
  type    = string
  default = "/apigateway/WebSocketChatAPI"
}

variable "http_apigateway_log_path" {
  type    = string
  default = "/apigateway/HTTPChatAPI"
}

variable "lambda_log_path" {
  type    = string
  default = "/aws/lambda"
}

variable "log_keep_day" {
  type    = number
  default = 7
}

# variable "secret" {
#   type = string
# }
