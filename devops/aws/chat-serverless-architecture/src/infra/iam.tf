### IAM Role for Lambda Functions ###
resource "aws_iam_role" "lambda_role" {
  name = "LambdaRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

### IAM Policies ###

# Policy for DynamoDB Access
resource "aws_iam_policy" "dynamodb_policy" {
  name        = "DynamoDBAccessPolicy"
  description = "Policy for Lambda to access DynamoDB tables."
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query"
        ],
        "Resource" : [
          aws_dynamodb_table.chat_room.arn
        ]
      }
    ]
  })
}

# Policy for API Gateway Management (WebSocket)
resource "aws_iam_policy" "manage_connections_policy" {
  name        = "ApiGatewayManageConnectionsPolicy"
  description = "Policy for Lambda to manage API Gateway WebSocket connections."
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "execute-api:ManageConnections",
        "Resource" : "*"
      }
    ]
  })
}

### Attach Policies to IAM Role ###
resource "aws_iam_role_policy_attachment" "attach_dynamodb_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_manage_connections_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.manage_connections_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
