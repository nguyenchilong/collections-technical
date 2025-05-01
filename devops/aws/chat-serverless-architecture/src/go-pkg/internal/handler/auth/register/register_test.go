package register_test

import (
	"context"
	"testing"

	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/auth/register"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/common"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/mocksrv"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

func TestRegisterHandler(t *testing.T) {

	t.Run("200 Response", func(t *testing.T) {
		mDDB := &mocksrv.MockDynamoDB{}
		mDDB.On("GetItem", mock.Anything, mock.Anything).Return(&dynamodb.GetItemOutput{}, nil)
		mDDB.On("PutItem", mock.Anything, mock.Anything).Return(&dynamodb.PutItemOutput{}, nil)
		ctx := context.Background()

		handler := register.RegisterHandler(mDDB)
		resp, err := handler(ctx, events.APIGatewayProxyRequest{
			Body: `{
				"username": "test-user",
				"email": "abc@gamil.com",
				"password": "pwd"
			}`,
		})

		assert.Nil(t, err)
		assert.Equal(t, common.ApiResponse(common.Success, nil), resp)
	})
}
