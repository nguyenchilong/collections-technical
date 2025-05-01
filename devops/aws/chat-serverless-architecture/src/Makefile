PROJECTNAME := $(shell basename "$(PWD)")

GO_PACKAGE_PATH = "./go-pkg"
INPUT_PATH = "./sls"
MAIN_FILE = "main.go"
OUTPUT_PATH = "./../infra/tf_generated"
BINARY_FILE_NAME = "bootstrap"
BUILD_OS = "linux"
ARCHITECTURE = "arm64"

LOGIN_OUTPUT_PATH = "${OUTPUT_PATH}/auth_login/${BINARY_FILE_NAME}"
LOGIN_INPUT_PATH = "${INPUT_PATH}/auth-login/${MAIN_FILE}"

REGISTER_OUTPUT_PATH = "${OUTPUT_PATH}/auth_register/${BINARY_FILE_NAME}"
REGISTER_INPUT_PATH = "${INPUT_PATH}/auth-register/${MAIN_FILE}"

CONNECT_OUTPUT_PATH = "${OUTPUT_PATH}/chat_connect/${BINARY_FILE_NAME}"
CONNECT_INPUT_PATH = "${INPUT_PATH}/chat-connect/${MAIN_FILE}"

DISCONNECT_OUTPUT_PATH = "${OUTPUT_PATH}/chat_disconnect/${BINARY_FILE_NAME}"
DISCONNECT_INPUT_PATH = "${INPUT_PATH}/chat-disconnect/${MAIN_FILE}"

MESSAGE_OUTPUT_PATH = "${OUTPUT_PATH}/chat_message/${BINARY_FILE_NAME}"
MESSAGE_INPUT_PATH = "${INPUT_PATH}/chat-message/${MAIN_FILE}"


## Build Go package
.PHONY: build
build:
	@ GOOS=${BUILD_OS} GOARCH=${ARCHITECTURE} go build -C ${GO_PACKAGE_PATH} -tags lambda.norpc -o ${LOGIN_OUTPUT_PATH} ${LOGIN_INPUT_PATH}
	@ GOOS=${BUILD_OS} GOARCH=${ARCHITECTURE} go build -C ${GO_PACKAGE_PATH} -tags lambda.norpc -o ${REGISTER_OUTPUT_PATH} ${REGISTER_INPUT_PATH}
	@ GOOS=${BUILD_OS} GOARCH=${ARCHITECTURE} go build -C ${GO_PACKAGE_PATH} -tags lambda.norpc -o ${CONNECT_OUTPUT_PATH} ${CONNECT_INPUT_PATH}
	@ GOOS=${BUILD_OS} GOARCH=${ARCHITECTURE} go build -C ${GO_PACKAGE_PATH} -tags lambda.norpc -o ${DISCONNECT_OUTPUT_PATH} ${DISCONNECT_INPUT_PATH}
	@ GOOS=${BUILD_OS} GOARCH=${ARCHITECTURE} go build -C ${GO_PACKAGE_PATH} -tags lambda.norpc -o ${MESSAGE_OUTPUT_PATH} ${MESSAGE_INPUT_PATH}

.PHONY: init
init:
	@ terraform -chdir=./infra init 

.PHONY: plan
plan:
	@ terraform -chdir=./infra plan 

.PHONY: apply
apply:
	@ terraform -chdir=./infra apply -auto-approve

.PHONY: destroy
destroy:
	@ terraform -chdir=./infra destroy -auto-approve