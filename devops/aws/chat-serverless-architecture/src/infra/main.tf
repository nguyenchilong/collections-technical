provider "aws" {
  region = var.region
}

### Lambda Permissions for API Gateway ###
resource "aws_lambda_permission" "allow_connect" {
  statement_id  = "AllowConnectInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.connect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*"
}

resource "aws_lambda_permission" "allow_disconnect" {
  statement_id  = "AllowDisconnectInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.disconnect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*"
}

resource "aws_lambda_permission" "allow_send_message" {
  statement_id  = "AllowSendMessageInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_message.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*"
}

resource "aws_lambda_permission" "allow_register" {
  statement_id  = "AllowRegisterInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.register.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*"
}

resource "aws_lambda_permission" "allow_login" {
  statement_id  = "AllowLoginInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*"
}

### Deployment and Stage for WebSocket API ###
resource "aws_apigatewayv2_stage" "prod_websocket" {
  api_id      = aws_apigatewayv2_api.websocket_api.id
  name        = "prod"
  auto_deploy = true
}

### Deployment and Stage for HTTP API ###
resource "aws_apigatewayv2_stage" "prod_http" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "prod"
  auto_deploy = true
}

output "websocket_api_endpoint" {
  value = aws_apigatewayv2_api.websocket_api.api_endpoint
}

output "http_api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "private_key" {
  value = random_string.random.result
}
