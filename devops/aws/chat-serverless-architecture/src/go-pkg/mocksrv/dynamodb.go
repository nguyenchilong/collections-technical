package mocksrv

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/stretchr/testify/mock"
)

type MockDynamoDB struct {
	mock.Mock
}

func (s *MockDynamoDB) PutItem(ctx context.Context, params *dynamodb.PutItemInput, optFns ...func(*dynamodb.Options)) (*dynamodb.PutItemOutput, error) {
	args := s.Called(params)
	return args.Get(0).(*dynamodb.PutItemOutput), args.Error(1)
}
func (s *MockDynamoDB) DeleteItem(ctx context.Context, params *dynamodb.DeleteItemInput, optFns ...func(*dynamodb.Options)) (*dynamodb.DeleteItemOutput, error) {
	args := s.Called(params)
	return args.Get(0).(*dynamodb.DeleteItemOutput), args.Error(1)
}
func (s *MockDynamoDB) Scan(ctx context.Context, params *dynamodb.ScanInput, optFns ...func(*dynamodb.Options)) (*dynamodb.ScanOutput, error) {
	args := s.Called(params)
	return args.Get(0).(*dynamodb.ScanOutput), args.Error(1)
}

func (s *MockDynamoDB) GetItem(ctx context.Context, params *dynamodb.GetItemInput, optFns ...func(*dynamodb.Options)) (*dynamodb.GetItemOutput, error) {
	args := s.Called(params)
	return args.Get(0).(*dynamodb.GetItemOutput), args.Error(1)
}

func (s *MockDynamoDB) Query(ctx context.Context, params *dynamodb.QueryInput, optFns ...func(*dynamodb.Options)) (*dynamodb.QueryOutput, error) {
	args := s.Called(params)
	return args.Get(0).(*dynamodb.QueryOutput), args.Error(1)
}
