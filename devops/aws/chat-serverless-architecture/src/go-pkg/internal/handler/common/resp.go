package common

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/aws/aws-lambda-go/events"
)

const (
	Success StatusId = 0

	// General error 100 ~ 999
	// Naming: ErrorXXXXX
	ErrorInternal   StatusId = 100
	ErrorValidation StatusId = 101
)

var statusDefs = map[StatusId]StatusDef{
	Success: {
		httpStatus: http.StatusOK,
		msgFmt:     "Success",
	},

	ErrorInternal: {
		httpStatus: http.StatusInternalServerError,
		msgFmt:     "Server encounters an internal error. Try again later",
	},

	ErrorValidation: {
		httpStatus: http.StatusBadRequest,
		msgFmt:     "Request validation failed",
	},
}

// ApiResponse - Unified return response interface format
func ApiResponse(code StatusId, data interface{}) events.APIGatewayProxyResponse {
	// Get status definition
	statusDef, ok := statusDefs[code]
	if !ok {
		statusDef = statusDefs[ErrorInternal]
		data = nil
	}

	body := ResponseData{
		Status:      code,
		Message:     statusDef.msgFmt,
		Data:        data,
		CurrentTime: time.Now().UnixMilli(),
	}
	b, _ := json.Marshal(body)

	// Return response
	return events.APIGatewayProxyResponse{
		StatusCode: statusDef.httpStatus,
		Body:       string(b),
	}
}
