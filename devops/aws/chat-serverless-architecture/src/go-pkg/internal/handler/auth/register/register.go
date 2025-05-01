package register

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/iaws"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/auth"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/common"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/utils"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

func RegisterHandler(dbClient iaws.IdynamoDB) common.Handler[events.APIGatewayProxyRequest] {
	return func(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
		msg := &auth.RegisterRequest{}
		err := json.Unmarshal([]byte(req.Body), msg)
		if err != nil {
			log.Printf("Error parsing message: %s", err)
			return common.ApiResponse(common.ErrorValidation, nil), nil
		}

		if utils.Empty(msg.Email) || utils.Empty(msg.Password) || utils.Empty(msg.Username) {
			return common.ApiResponse(common.ErrorValidation, nil), nil
		}

		if !utils.VerifyEmailFormat(msg.Email) {
			return common.ApiResponse(common.ErrorValidation, nil), nil
		}
		output, err := dbClient.GetItem(ctx, &dynamodb.GetItemInput{
			TableName: aws.String(os.Getenv(auth.TABLE_NAME)),
			Key: map[string]types.AttributeValue{
				common.PK: &types.AttributeValueMemberS{Value: fmt.Sprintf(auth.USER_PREFIX, msg.Email)},
				common.SK: &types.AttributeValueMemberS{Value: fmt.Sprintf(auth.USER_PREFIX, msg.Email)},
			},
		})
		if err != nil {
			log.Printf("Error getting data: %s", err)
			return common.ApiResponse(common.ErrorInternal, nil), nil
		}

		if output.Item != nil {
			log.Printf("Error register user exist. user: %s", msg.Email)
			return common.ApiResponse(common.ErrorValidation, nil), nil
		}

		salt := utils.CreateNewSalt()

		hash, err := salt.SaltInput(msg.Password)
		if err != nil {
			log.Printf("Error getting hash: %s", err)
			return common.ApiResponse(common.ErrorInternal, nil), nil
		}

		msg = &auth.RegisterRequest{
			Email:    fmt.Sprintf(auth.USER_PREFIX, msg.Email),
			SK:       fmt.Sprintf(auth.USER_PREFIX, msg.Email),
			Password: hash,
			Username: msg.Username,
			Salt:     salt.SaltString,
		}

		data, err := attributevalue.MarshalMap(msg)
		if err != nil {
			log.Printf("Error parse data: %s", err)
			return common.ApiResponse(common.ErrorInternal, nil), nil
		}

		_, err = dbClient.PutItem(ctx, &dynamodb.PutItemInput{
			TableName:           aws.String(os.Getenv(auth.TABLE_NAME)),
			Item:                data,
			ConditionExpression: aws.String(common.PkNotExists),
		})

		if err != nil {
			log.Printf("Error putting data: %s", err)
			return common.ApiResponse(common.ErrorInternal, nil), nil
		}

		return common.ApiResponse(common.Success, nil), nil
	}
}
