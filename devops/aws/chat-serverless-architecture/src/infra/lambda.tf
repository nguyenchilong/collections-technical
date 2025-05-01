// build the binary for the lambda function in a specified path
resource "null_resource" "chat_connect" {
  provisioner "local-exec" {
    command     = "GOOS=linux GOARCH=arm64 go build -tags lambda.norpc -o ./../infra/${local.generate_path}/${local.chat_connect}/${local.binary_file} ${local.chat_connect_src_path}"
    working_dir = local.go_pkg_file
  }
}

resource "null_resource" "chat_disconnect" {
  provisioner "local-exec" {
    command     = "GOOS=linux GOARCH=arm64 go build -tags lambda.norpc -o ./../infra/${local.generate_path}/${local.chat_disconnect}/${local.binary_file} ${local.chat_disconnect_src_path}"
    working_dir = local.go_pkg_file
  }
}

resource "null_resource" "chat_message" {
  provisioner "local-exec" {
    command     = "GOOS=linux GOARCH=arm64 go build -tags lambda.norpc -o ./../infra/${local.generate_path}/${local.chat_message}/${local.binary_file} ${local.chat_message_src_path}"
    working_dir = local.go_pkg_file
  }
}

resource "null_resource" "auth_register" {
  provisioner "local-exec" {
    command     = "GOOS=linux GOARCH=arm64 go build -tags lambda.norpc -o ./../infra/${local.generate_path}/${local.auth_register}/${local.binary_file} ${local.auth_register_src_path}"
    working_dir = local.go_pkg_file
  }
}

resource "null_resource" "auth_login" {
  provisioner "local-exec" {
    command     = "GOOS=linux GOARCH=arm64 go build -tags lambda.norpc -o ./../infra/${local.generate_path}/${local.auth_login}/${local.binary_file} ${local.auth_login_src_path}"
    working_dir = local.go_pkg_file
  }
}

// zip the binary, as we can use only zip files to AWS lambda
data "archive_file" "chat_connect_archive" {
  depends_on = [null_resource.chat_connect]

  type        = "zip"
  source_file = "${path.module}/${local.generate_path}/${local.chat_connect}/${local.binary_file}"
  output_path = local.chat_connect_archive_path
}

data "archive_file" "chat_disconnect_archive" {
  depends_on = [null_resource.chat_disconnect]

  type        = "zip"
  source_file = "${path.module}/${local.generate_path}/${local.chat_disconnect}/${local.binary_file}"
  output_path = local.chat_disconnect_archive_path
}

data "archive_file" "chat_message_archive" {
  depends_on = [null_resource.chat_message]

  type        = "zip"
  source_file = "${path.module}/${local.generate_path}/${local.chat_message}/${local.binary_file}"
  output_path = local.chat_message_archive_path
}

data "archive_file" "auth_register_archive" {
  depends_on = [null_resource.auth_register]

  type        = "zip"
  source_file = "${path.module}/${local.generate_path}/${local.auth_register}/${local.binary_file}"
  output_path = local.auth_register_archive_path
}

data "archive_file" "auth_login_archive" {
  depends_on = [null_resource.auth_login]

  type        = "zip"
  source_file = "${path.module}/${local.generate_path}/${local.auth_login}/${local.binary_file}"
  output_path = local.auth_login_archive_path
}

### Lambda Functions for WebSocket Routes ###
resource "aws_lambda_function" "connect" {
  function_name    = "ConnectFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = local.binary_file
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  filename         = local.chat_connect_archive_path
  source_code_hash = data.archive_file.chat_connect_archive.output_base64sha256
  environment {
    variables = {
      SECRET     = random_string.random.result
      TABLE_NAME = aws_dynamodb_table.chat_room.name
    }
  }
}

resource "aws_lambda_function" "disconnect" {
  function_name    = "DisconnectFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = local.binary_file
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  filename         = local.chat_disconnect_archive_path
  source_code_hash = data.archive_file.chat_disconnect_archive.output_base64sha256
  environment {
    variables = {
      SECRET     = random_string.random.result
      TABLE_NAME = aws_dynamodb_table.chat_room.name
    }
  }
}

resource "aws_lambda_function" "send_message" {
  function_name    = "SendMessageFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = local.binary_file
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  filename         = local.chat_message_archive_path
  source_code_hash = data.archive_file.chat_message_archive.output_base64sha256
  environment {
    variables = {
      TABLE_NAME      = aws_dynamodb_table.chat_room.name,
      API_ENDPOINT_ID = aws_apigatewayv2_api.websocket_api.id,
      STAGE           = aws_apigatewayv2_stage.prod_websocket.name
      SECRET          = random_string.random.result
    }
  }
}

resource "aws_lambda_function" "register" {
  function_name    = "RegisterFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = local.binary_file
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  filename         = local.auth_register_archive_path
  source_code_hash = data.archive_file.auth_register_archive.output_base64sha256
  environment {
    variables = {
      SECRET     = random_string.random.result
      TABLE_NAME = aws_dynamodb_table.chat_room.name
    }
  }
}

resource "aws_lambda_function" "login" {
  function_name    = "LoginFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = local.binary_file
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  filename         = local.auth_login_archive_path
  source_code_hash = data.archive_file.auth_login_archive.output_base64sha256
  environment {
    variables = {
      SECRET     = random_string.random.result
      TABLE_NAME = aws_dynamodb_table.chat_room.name
    }
  }
}
