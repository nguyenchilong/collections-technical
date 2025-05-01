package login

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"

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

func LoginHandler(dbClient iaws.IdynamoDB) common.Handler[events.APIGatewayProxyRequest] {
	return func(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
		msg := &auth.LoginRequest{}
		err := json.Unmarshal([]byte(req.Body), msg)
		if err != nil {
			log.Printf("Error parsing message: %s", err)
			return common.ApiResponse(common.ErrorValidation, nil), nil
		}

		if utils.Empty(msg.Email) || utils.Empty(msg.Password) || msg.RoomId <= 0 || msg.RoomId > 5 {
			return common.ApiResponse(common.ErrorValidation, nil), nil
		}

		if !utils.VerifyEmailFormat(msg.Email) {
			return common.ApiResponse(common.ErrorValidation, nil), nil
		}
		origPwd := msg.Password
		roomId := msg.RoomId
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

		if err := attributevalue.UnmarshalMap(output.Item, msg); err != nil {
			log.Printf("Error parse data: %s", err)
			return common.ApiResponse(common.ErrorInternal, nil), nil
		}

		salt, err := utils.CreateSaltByString(msg.Salt)
		if err != nil {
			log.Printf("Error creating salt: %s", err)
			return common.ApiResponse(common.ErrorInternal, nil), nil
		}

		if hash, err := salt.SaltInput(origPwd); err != nil {
			log.Printf("Error hashing password: %s", err)
			return common.ApiResponse(common.ErrorInternal, nil), nil
		} else if hash != msg.Password {
			return common.ApiResponse(common.ErrorValidation, nil), nil
		}

		email := strings.TrimPrefix(msg.Email, fmt.Sprintf(auth.USER_PREFIX, ""))

		token, err := common.GenerateJWT(email, roomId, os.Getenv(common.SECRET), auth.EXPIRE)
		if err != nil {
			log.Printf("Error generate token: %s", err)
			return common.ApiResponse(common.ErrorInternal, nil), nil
		}

		resp := &common.TokenInfo{
			Token: token,
		}
		return common.ApiResponse(common.Success, resp), nil
	}
}
