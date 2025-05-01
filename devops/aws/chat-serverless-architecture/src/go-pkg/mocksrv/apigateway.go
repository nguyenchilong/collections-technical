package mocksrv

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/service/apigatewaymanagementapi"
	"github.com/stretchr/testify/mock"
)

type MockApiGateway struct {
	mock.Mock
}

func (s *MockApiGateway) PostToConnection(ctx context.Context, params *apigatewaymanagementapi.PostToConnectionInput, optFns ...func(*apigatewaymanagementapi.Options)) (*apigatewaymanagementapi.PostToConnectionOutput, error) {
	args := s.Called(params)
	return args.Get(0).(*apigatewaymanagementapi.PostToConnectionOutput), args.Error(1)
}
