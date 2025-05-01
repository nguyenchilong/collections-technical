package disconnect_test

import (
	"context"
	"errors"
	"testing"

	chatDisconnect "github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/chat/disconnect"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/common"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/mocksrv"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

func TestDisconnectHandler(t *testing.T) {
	t.Run("200 Response", func(t *testing.T) {
		mDDB := &mocksrv.MockDynamoDB{}
		mDDB.On("DeleteItem", mock.Anything, mock.Anything).Return(&dynamodb.DeleteItemOutput{}, nil)
		ctx := context.Background()

		handler := chatDisconnect.DisconnectHandler(mDDB)

		resp, err := handler(ctx, events.APIGatewayWebsocketProxyRequest{})
		assert.Nil(t, err)
		assert.Equal(t, common.ApiResponse(common.Success, nil), resp)
	})

	t.Run("500 Response", func(t *testing.T) {
		mDDB := &mocksrv.MockDynamoDB{}
		mDDB.On("DeleteItem", mock.Anything, mock.Anything).Return(&dynamodb.DeleteItemOutput{}, errors.New("Oops!"))
		ctx := context.Background()

		handler := chatDisconnect.DisconnectHandler(mDDB)

		resp, err := handler(ctx, events.APIGatewayWebsocketProxyRequest{})
		assert.Nil(t, err)
		assert.Equal(t, common.ApiResponse(common.ErrorInternal, nil), resp)
	})
}
