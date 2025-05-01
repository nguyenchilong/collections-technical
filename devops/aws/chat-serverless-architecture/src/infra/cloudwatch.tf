resource "aws_cloudwatch_log_group" "api_gateway_log" {
  name              = var.apigateway_log_path
  retention_in_days = var.log_keep_day
  lifecycle {
    prevent_destroy = false
  }
}

// create log group in cloudwatch to gather logs of our lambda function
resource "aws_cloudwatch_log_group" "log_connect" {
  name              = "${var.lambda_log_path}/${aws_lambda_function.connect.function_name}"
  retention_in_days = var.log_keep_day
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "log_disconnect" {
  name              = "${var.lambda_log_path}/${aws_lambda_function.disconnect.function_name}"
  retention_in_days = var.log_keep_day
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "log_send_message" {
  name              = "${var.lambda_log_path}/${aws_lambda_function.send_message.function_name}"
  retention_in_days = var.log_keep_day
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "log_register" {
  name              = "${var.lambda_log_path}/${aws_lambda_function.register.function_name}"
  retention_in_days = var.log_keep_day
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "log_login" {
  name              = "${var.lambda_log_path}/${aws_lambda_function.login.function_name}"
  retention_in_days = var.log_keep_day
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "http_api_gateway_log" {
  name              = var.http_apigateway_log_path
  retention_in_days = var.log_keep_day
  lifecycle {
    prevent_destroy = false
  }
}
