package common

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
)

func TokenMiddleware[input Request](next Handler[input]) Handler[input] {
	return func(ctx context.Context, req input) (events.APIGatewayProxyResponse, error) {
		data := strings.Split(getQueryParameter(req, TOKEN), " ")
		if len(data) < 2 {
			log.Printf("Error getting token, %s", data)
			return ApiResponse(ErrorValidation, nil), nil
		}
		token := data[1]
		email, roomId, err := ExtractToken(token)
		if err != nil {
			log.Printf("Error getting token, %s, secret: %s", token, os.Getenv(SECRET))
			return ApiResponse(ErrorValidation, nil), nil
		}
		setUser(req, email)
		setRoomId(req, roomId)
		return next(ctx, req)
	}
}

func getQueryParameter(data any, key string) string {
	switch data := data.(type) {
	case events.APIGatewayWebsocketProxyRequest:
		return data.QueryStringParameters[key]
	case events.APIGatewayProxyRequest:
		return data.QueryStringParameters[key]
	default:
		return ""
	}
}

func setRoomId(data any, roomId int) {
	switch data := data.(type) {
	case events.APIGatewayWebsocketProxyRequest:
		data.Headers[ROOM] = fmt.Sprintf("%d", roomId)
	case events.APIGatewayProxyRequest:
		data.Headers[ROOM] = fmt.Sprintf("%d", roomId)
	}
}

func setUser(data any, user string) {
	switch data := data.(type) {
	case events.APIGatewayWebsocketProxyRequest:
		data.Headers[USER] = user
	case events.APIGatewayProxyRequest:
		data.Headers[USER] = user
	}
}
