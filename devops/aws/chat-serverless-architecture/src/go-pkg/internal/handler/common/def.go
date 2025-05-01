package common

import (
	"context"

	"github.com/aws/aws-lambda-go/events"
)

const (
	USER   = "User"
	ROOM   = "Room"
	SECRET = "SECRET"
	TOKEN  = "Token"
)

var (
	PK                 = "PK"
	SK                 = "SK"
	PkNotExists string = "attribute_not_exists(pk)"
	PkExists    string = "attribute_exists(pk)"
)

type StatusId int

type StatusDef struct {
	httpStatus int
	msgFmt     string
}

type ResponseData struct {
	Status      StatusId    `json:"status"`
	Message     string      `json:"message"`
	CurrentTime int64       `json:"current_time,omitempty"`
	Data        interface{} `json:"data,omitempty"`
}

type Handler[in Request] func(ctx context.Context, req in) (events.APIGatewayProxyResponse, error)

type Request interface {
	events.APIGatewayWebsocketProxyRequest | events.APIGatewayProxyRequest
}
