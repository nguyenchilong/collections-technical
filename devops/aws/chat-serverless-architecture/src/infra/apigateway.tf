### API Gateway WebSocket API ###
resource "aws_apigatewayv2_api" "websocket_api" {
  name                       = "WebSocketChatAPI"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

### API Gateway HTTP API ###
resource "aws_apigatewayv2_api" "http_api" {
  name          = "HTTPChatAPI"
  protocol_type = "HTTP"
}

### API Gateway Integrations ###
resource "aws_apigatewayv2_integration" "connect" {
  api_id           = aws_apigatewayv2_api.websocket_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.connect.invoke_arn
}

resource "aws_apigatewayv2_integration" "disconnect" {
  api_id           = aws_apigatewayv2_api.websocket_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.disconnect.invoke_arn
}

resource "aws_apigatewayv2_integration" "send_message" {
  api_id           = aws_apigatewayv2_api.websocket_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.send_message.invoke_arn
}

resource "aws_apigatewayv2_integration" "auth_register" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY" # AWS_PROXY enables Lambda proxy integration
  integration_uri        = aws_lambda_function.register.invoke_arn
  payload_format_version = "2.0" # For HTTP APIs, use payload version 2.0
}

resource "aws_apigatewayv2_integration" "auth_login" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY" # AWS_PROXY enables Lambda proxy integration
  integration_uri        = aws_lambda_function.login.invoke_arn
  payload_format_version = "2.0" # For HTTP APIs, use payload version 2.0
}

### API Gateway Routes ###
resource "aws_apigatewayv2_route" "connect_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.connect.id}"
}

resource "aws_apigatewayv2_route" "disconnect_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.disconnect.id}"
}

resource "aws_apigatewayv2_route" "send_message_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "sendMessage"
  target    = "integrations/${aws_apigatewayv2_integration.send_message.id}"
}

resource "aws_apigatewayv2_route" "auth_register_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /auth/v1/register" # Defines HTTP method and path
  target    = "integrations/${aws_apigatewayv2_integration.auth_register.id}"
}

resource "aws_apigatewayv2_route" "auth_login_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /auth/v1/login" # Defines HTTP method and path
  target    = "integrations/${aws_apigatewayv2_integration.auth_login.id}"
}
