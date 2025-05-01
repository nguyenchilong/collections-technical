package main

import (
	"context"
	"log"

	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/auth/register"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
)

var dbClient *dynamodb.Client

func init() {
	// Load AWS configuration and initialize the DynamoDB client
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}

	dbClient = dynamodb.NewFromConfig(cfg)
}

func main() {
	lambda.Start(register.RegisterHandler(dbClient))
}
