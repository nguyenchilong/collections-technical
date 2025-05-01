package main

import (
	"context"
	"fmt"
	"log"
	"os"

	chatMessage "github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/chat/send-message"
	"github.com/0x726f6f6b6965/real-time-chat/go-pkg/internal/handler/common"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/apigatewaymanagementapi"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	smithyendpoints "github.com/aws/smithy-go/endpoints"
)

var (
	dbClient  *dynamodb.Client
	apiClient *apigatewaymanagementapi.Client
)

type resolverV2 struct{}

func init() {
	// Load AWS configuration
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}

	// Initialize the DynamoDB client
	dbClient = dynamodb.NewFromConfig(cfg)

	// get env value
	var (
		region     = os.Getenv("AWS_REGION")
		endpointID = os.Getenv("API_ENDPOINT_ID")
		stage      = os.Getenv("STAGE")
	)

	// Initialize the API Gateway Management API client
	apiClient = apigatewaymanagementapi.NewFromConfig(cfg, func(o *apigatewaymanagementapi.Options) {
		o.BaseEndpoint = aws.String(fmt.Sprintf("https://%s.execute-api.%s.amazonaws.com/%s", endpointID, region, stage))
		o.EndpointResolverV2 = &resolverV2{}
	})
}

func main() {
	lambda.Start(common.TokenMiddleware(chatMessage.SendMessageHandler(dbClient, apiClient)))
}

func (*resolverV2) ResolveEndpoint(ctx context.Context, params apigatewaymanagementapi.EndpointParameters) (smithyendpoints.Endpoint, error) {
	// s3.Options.BaseEndpoint is accessible here:
	log.Printf("The endpoint provided in config is %s\n", *params.Endpoint)

	// fallback to default
	return apigatewaymanagementapi.NewDefaultEndpointResolverV2().ResolveEndpoint(ctx, params)
}
