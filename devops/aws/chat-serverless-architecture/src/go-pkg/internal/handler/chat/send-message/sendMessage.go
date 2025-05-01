package message

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/iaws"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/chat"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/common"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/expression"
	"github.com/aws/aws-sdk-go-v2/service/apigatewaymanagementapi"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

func SendMessageHandler(dbClient iaws.IdynamoDB, apiClient iaws.IapiGateway) common.Handler[events.APIGatewayWebsocketProxyRequest] {
	return func(ctx context.Context, req events.APIGatewayWebsocketProxyRequest) (events.APIGatewayProxyResponse, error) {
		// Parse the message from the request body
		roomId := req.Headers[common.ROOM]
		email := req.Headers[common.USER]
		msg := chat.Message{}
		err := json.Unmarshal([]byte(req.Body), &msg)
		if err != nil {
			log.Printf("Error parsing message: %s", err)
			return common.ApiResponse(common.ErrorValidation, nil), nil
		}
		msg.ConnId = req.RequestContext.ConnectionID
		msg.RoomId = fmt.Sprintf(chat.RoomIdPrefix, roomId)
		msg.From = email
		now := time.Now()
		msg.CreatedAt = fmt.Sprintf(chat.MessagePrefix, now.String())
		msg.TTL = now.Add(time.Hour * 24 * 7).Unix()

		data, err := attributevalue.MarshalMap(&msg)
		if err != nil {
			log.Printf("Error parse data: %s", err)
			return common.ApiResponse(common.ErrorInternal, nil), nil
		}

		// Save the message in DynamoDB (for chat history)
		_, err = dbClient.PutItem(ctx, &dynamodb.PutItemInput{
			TableName:           aws.String(os.Getenv(chat.TABLE_NAME)),
			Item:                data,
			ConditionExpression: aws.String(common.PkNotExists),
		})

		if err != nil {
			log.Printf("Error saving message: %s", err)
			return common.ApiResponse(common.ErrorInternal, nil), nil
		}

		// Fetch all connected clients from DynamoDB
		result, err := getRoomUsers(ctx, dbClient, roomId)
		if err != nil {
			log.Printf("Error get room connections: %s", err)
			return common.ApiResponse(common.ErrorInternal, nil), nil
		}

		// Broadcast the message to all connected clients
		for _, item := range result {
			connID := item.ConnID

			if connID == msg.ConnId {
				continue
			}
			err := sendMessageToClient(ctx, connID, &msg, apiClient)
			if err != nil {
				log.Printf("Error sending message to client %s: %s", connID, err)
				// Optionally, delete the connection if sending fails
				_, _ = dbClient.DeleteItem(ctx, &dynamodb.DeleteItemInput{
					TableName: aws.String(os.Getenv(chat.TABLE_NAME)),
					Key: map[string]types.AttributeValue{
						common.PK: &types.AttributeValueMemberS{Value: fmt.Sprintf(chat.RoomIdPrefix, roomId)},
						common.SK: &types.AttributeValueMemberS{Value: fmt.Sprintf(chat.ConnectionPrefix, req.RequestContext.ConnectionID)},
					},
					ConditionExpression: aws.String(common.PkExists),
				})
			}
		}

		return common.ApiResponse(common.Success, nil), nil
	}
}

func sendMessageToClient(ctx context.Context, connectionID string, message *chat.Message, apiClient iaws.IapiGateway) error {
	messageBytes, err := json.Marshal(message)
	if err != nil {
		return err
	}

	_, err = apiClient.PostToConnection(ctx, &apigatewaymanagementapi.PostToConnectionInput{
		ConnectionId: aws.String(connectionID),
		Data:         messageBytes,
	})
	if err != nil {

		return fmt.Errorf("failed to post message: %w", err)
	}
	return nil
}

func getRoomUsers(ctx context.Context, dbClient iaws.IdynamoDB, roomId string) ([]chat.ConnectionData, error) {
	var (
		response *dynamodb.QueryOutput
		output   []chat.ConnectionData
	)

	keyEx := expression.Key(common.PK).Equal(expression.Value(fmt.Sprintf(chat.RoomIdPrefix, roomId))).And(
		expression.KeyBeginsWith(expression.Key(common.SK), fmt.Sprintf(chat.MessagePrefix, "")))

	expr, err := expression.NewBuilder().WithKeyCondition(keyEx).Build()
	if err != nil {
		return output, err
	}
	queryPaginator := dynamodb.NewQueryPaginator(dbClient, &dynamodb.QueryInput{
		TableName:                 aws.String(chat.TABLE_NAME),
		ExpressionAttributeNames:  expr.Names(),
		ExpressionAttributeValues: expr.Values(),
		KeyConditionExpression:    expr.KeyCondition(),
		AttributesToGet:           []string{common.PK, common.SK},
	})

	for queryPaginator.HasMorePages() {
		response, err = queryPaginator.NextPage(ctx)
		if err != nil {
			break
		}
		var outputPage []chat.ConnectionData
		err = attributevalue.UnmarshalListOfMaps(response.Items, &outputPage)
		if err != nil {
			break
		}
		output = append(output, outputPage...)
	}
	return output, err
}
