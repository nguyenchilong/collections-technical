# Chat Room

## Requirements

1. As a user, I need to connect to the chat room and disconnect from it.
2. As a user, I want to send messages to a chat room and receive messages from others.
3. As a user, I would like to register as a member.
4. As a user, I should be able to log into the service.

## Components

1. API Gateway (WebSocket API): Handles real-time communication between clients (browsers, mobile apps, etc.) and your backend.
2. AWS Lambda: Processes chat events (messages, connection, disconnection) and interacts with DynamoDB for storing and retrieving the chat history.
3. DynamoDB: A NoSQL database used to store the chat messages and connection information.

### Register

- API Gateway will trigger the register lambda function via the `POST /auth/v1/reister` router.
  - `PK`
    - The field will store `USER#{email}`.
  - `SK`
    - The field will store `USER#{email}`.
  - `Username`
  - `Password`
  - `Salt`

| #   | access pattern       | target | action   | pk             | sk             | done               |
| --- | -------------------- | ------ | -------- | -------------- | -------------- | ------------------ |
| 1   | set user information | table  | put item | `USER#{email}` | `USER#{email}` | :white_check_mark: |
| 2   | get user information | table  | get item | `USER#{email}` | `USER#{email}` | :white_check_mark: |

### Login

- API Gateway will trigger the login lambda function via the `POST /auth/v1/login` router.
- It will return the JSON Web Token if the authentication is successful.
- The token will include `email`, `room_id`, and `expire`.

### Connection

- API Gateway will trigger the connect lambda function via the `$connect` router.
- This function can store connection details (like connection ID) in a DynamoDB table to track active users.
  - `PK`
    - The field will store `ROOM#{room_id}`.
  - `SK`
    - The field will store `CONN#{connection_id}`.

### Disconnection

- API Gateway will trigger the disconnect lambda function via the `$disconnect` router.
- This function will delete connection details (like connection ID) in a DynamoDB table.

| #   | access pattern                | target | action      | pk               | sk                     | done               |
| --- | ----------------------------- | ------ | ----------- | ---------------- | ---------------------- | ------------------ |
| 1   | set connection information    | table  | put item    | `ROOM#{room_id}` | `CONN#{connection_id}` | :white_check_mark: |
| 2   | delete connection information | table  | delete item | `ROOM#{room_id}` | `CONN#{connection_id}` | :white_check_mark: |

### SendMessage

- API Gateway will trigger the disconnect lambda function via the `sendMessage` router.
- This function will store message details in a DynamoDB table for future design.
  - `PK`
    - The field will store `ROOM#{room_id}`.
  - `SK`
    - The field will store `MESSAGE#{timestamp}`.
  - `Content`
    - The field will store `message`.
  - `From`
    - The field will store `email` which is the sender.
  - `TTL`
    - The field will store the time to live.
- The message will be send to all connected clients using the WebSocket connection IDs (by invoking the API Gateway callback URL).

| #   | access pattern                         | target | action     | pk               | sk                    | done               |
| --- | -------------------------------------- | ------ | ---------- | ---------------- | --------------------- | ------------------ |
| 1   | save message information               | table  | put item   | `ROOM#{room_id}` | `MESSAGE#{timestamp}` | :white_check_mark: |
| 2   | scan all connected clients in the room | table  | query item | `ROOM#{room_id}` | BeginWith `CONN#`     | :white_check_mark: |
