package message_test

import (
	"context"
	"errors"
	"fmt"
	"testing"
	"time"

	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/chat"
	chatMessage "github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/chat/send-message"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/common"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/mocksrv"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go-v2/service/apigatewaymanagementapi"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

func TestSendMessageHandler(t *testing.T) {
	t.Run("200 Response", func(t *testing.T) {
		mDDB := &mocksrv.MockDynamoDB{}
		mGateway := &mocksrv.MockApiGateway{}
		mDDB.On("PutItem", mock.Anything, mock.Anything).Return(&dynamodb.PutItemOutput{}, nil)
		mDDB.On("Query", mock.Anything, mock.Anything).Return(&dynamodb.QueryOutput{
			Items: []map[string]types.AttributeValue{
				{
					"PK": &types.AttributeValueMemberS{Value: fmt.Sprintf(chat.RoomIdPrefix, "1")},
					"SK": &types.AttributeValueMemberS{Value: fmt.Sprintf(chat.MessagePrefix, time.Now().String())},
				},
				{
					"PK": &types.AttributeValueMemberS{Value: fmt.Sprintf(chat.RoomIdPrefix, "2")},
					"SK": &types.AttributeValueMemberS{Value: fmt.Sprintf(chat.MessagePrefix, time.Now().String())},
				},
			},
		}, nil)
		mGateway.On("PostToConnection", mock.Anything, mock.Anything).Return(&apigatewaymanagementapi.PostToConnectionOutput{}, nil)
		ctx := context.Background()

		handler := chatMessage.SendMessageHandler(mDDB, mGateway)

		resp, err := handler(ctx, events.APIGatewayWebsocketProxyRequest{
			Headers: map[string]string{common.ROOM: "1"},
			Body: `{
				"content": "Hello, World!"
			}`,
			RequestContext: events.APIGatewayWebsocketProxyRequestContext{
				ConnectionID: "1",
			},
		})
		assert.Nil(t, err)
		assert.Equal(t, common.ApiResponse(common.Success, nil), resp)
	})

	t.Run("400 Response", func(t *testing.T) {
		mDDB := &mocksrv.MockDynamoDB{}
		mGateway := &mocksrv.MockApiGateway{}
		mDDB.On("PutItem", mock.Anything, mock.Anything).Return(&dynamodb.PutItemOutput{}, nil)
		ctx := context.Background()

		handler := chatMessage.SendMessageHandler(mDDB, mGateway)

		resp, err := handler(ctx, events.APIGatewayWebsocketProxyRequest{})
		assert.Nil(t, err)
		assert.Equal(t, common.ApiResponse(common.ErrorValidation, nil), resp)
	})

	t.Run("500 Response", func(t *testing.T) {
		mDDB := &mocksrv.MockDynamoDB{}
		mGateway := &mocksrv.MockApiGateway{}
		mDDB.On("PutItem", mock.Anything, mock.Anything).Return(&dynamodb.PutItemOutput{}, errors.New("Oops!"))
		ctx := context.Background()

		handler := chatMessage.SendMessageHandler(mDDB, mGateway)

		resp, err := handler(ctx, events.APIGatewayWebsocketProxyRequest{
			Body: `{
				"message": "Hello, World!"
			}`,
			RequestContext: events.APIGatewayWebsocketProxyRequestContext{
				ConnectionID: "1",
			},
		})
		assert.Nil(t, err)
		assert.Equal(t, common.ApiResponse(common.ErrorInternal, nil), resp)
	})

	t.Run("500 Response 2", func(t *testing.T) {
		mDDB := &mocksrv.MockDynamoDB{}
		mGateway := &mocksrv.MockApiGateway{}
		mDDB.On("PutItem", mock.Anything, mock.Anything).Return(&dynamodb.PutItemOutput{}, nil)
		mDDB.On("Query", mock.Anything, mock.Anything).Return(&dynamodb.QueryOutput{}, errors.New("Oops!"))
		ctx := context.Background()

		handler := chatMessage.SendMessageHandler(mDDB, mGateway)

		resp, err := handler(ctx, events.APIGatewayWebsocketProxyRequest{
			Body: `{
				"message": "Hello, World!"
			}`,
			RequestContext: events.APIGatewayWebsocketProxyRequestContext{
				ConnectionID: "1",
			},
		})
		assert.Nil(t, err)
		assert.Equal(t, common.ApiResponse(common.ErrorInternal, nil), resp)
	})
}
