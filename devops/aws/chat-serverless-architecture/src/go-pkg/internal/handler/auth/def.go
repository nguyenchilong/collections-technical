package auth

import "time"

const (
	TABLE_NAME = "TABLE_NAME"
)

var (
	USER_PREFIX               = "USER#%s"
	EXPIRE      time.Duration = 30 * time.Minute
)

type LoginRequest struct {
	Email    string `json:"email" dynamodbav:"PK"`
	RoomId   int    `json:"room_id" dynamodbav:"-"`
	Password string `json:"password" dynamodbav:"Password"`
	Salt     string `json:"-" dynamodbav:"Salt"`
}

type RegisterRequest struct {
	Username string `json:"username" dynamodbav:"Username"`
	Email    string `json:"email" dynamodbav:"PK"`
	SK       string `json:"-" dynamodbav:"SK"`
	Password string `json:"password" dynamodbav:"Password"`
	Salt     string `json:"-" dynamodbav:"Salt"`
}

type RegisterResponse struct {
	Token string `json:"token"`
}
