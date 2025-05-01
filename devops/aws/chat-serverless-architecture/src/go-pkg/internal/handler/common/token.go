package common

import (
	"errors"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type TokenInfo struct {
	Token string `json:"token"`
}

var (
	ErrInValid = errors.New("token invalid")
	ErrCode    = -1
)

// generates a new JWT token
func GenerateJWT(email string, roomId int, secret string, expire time.Duration) (string, error) {
	// create a JWT claim
	claims := jwt.MapClaims{}
	// assign an expiration time for the token
	claims["exp"] = time.Now().Add(expire).Unix()
	// assign a data for email
	claims["user"] = email
	// assign a data for roomId
	claims["roomId"] = roomId

	// create a JWT token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	// convert the JWT token into the string
	t, err := token.SignedString([]byte(secret))

	// if conversion is failed, return an error
	if err != nil {
		return "", err
	}

	// return the generated JWT token
	return t, nil
}

func ExtractToken(tokenString string) (string, int, error) {
	token, err := jwt.Parse(tokenString, jwtKeyFunc)
	if err != nil {
		return "", ErrCode, err
	}
	// get a JWT claim from the JWT token
	claims, ok := token.Claims.(jwt.MapClaims)
	// check if the token is valid
	var isValid bool = ok && token.Valid
	if !isValid {
		return "", ErrCode, ErrInValid
	}
	// get the email from the JWT claim
	email, ok := claims["user"].(string)
	if !ok {
		return "", ErrCode, ErrInValid
	}
	// get the email from the JWT claim
	roomId, ok := claims["roomId"].(float64)
	if !ok {
		return "", ErrCode, ErrInValid
	}
	return email, int(roomId), nil
}

// jwtKeyFunc return JWT secret key
func jwtKeyFunc(*jwt.Token) (interface{}, error) {
	return []byte(os.Getenv(SECRET)), nil
}
