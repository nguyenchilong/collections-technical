package login_test

import (
	"context"
	"testing"

	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/auth/login"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/common"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/mocksrv"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/utils"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

func TestRegisterHandler(t *testing.T) {
	salt := utils.CreateNewSalt()
	pwd, _ := salt.SaltInput("pwd")
	t.Run("200 Response", func(t *testing.T) {
		mDDB := &mocksrv.MockDynamoDB{}
		mDDB.On("GetItem", mock.Anything, mock.Anything).Return(&dynamodb.GetItemOutput{
			Item: map[string]types.AttributeValue{
				"PK":       &types.AttributeValueMemberS{Value: "abc@gamil.com"},
				"password": &types.AttributeValueMemberS{Value: pwd},
				"salt":     &types.AttributeValueMemberS{Value: salt.SaltString},
			},
		}, nil)
		ctx := context.Background()

		handler := login.LoginHandler(mDDB)
		resp, err := handler(ctx, events.APIGatewayProxyRequest{
			Body: `{
				"email": "abc@gamil.com",
				"password": "pwd",
				"room_id": 5
			}`,
		})

		assert.Nil(t, err)
		assert.Equal(t, common.ApiResponse(common.Success, nil).StatusCode, resp.StatusCode)
	})
}
