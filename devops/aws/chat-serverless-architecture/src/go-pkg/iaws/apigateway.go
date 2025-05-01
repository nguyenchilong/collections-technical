package iaws

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/service/apigatewaymanagementapi"
)

type IapiGateway interface {
	PostToConnection(ctx context.Context, params *apigatewaymanagementapi.PostToConnectionInput, optFns ...func(*apigatewaymanagementapi.Options)) (*apigatewaymanagementapi.PostToConnectionOutput, error)
}
