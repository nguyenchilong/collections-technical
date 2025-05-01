package chat

const (
	TABLE_NAME = "TABLE_NAME"
)

var (
	RoomIdPrefix     = "ROOM#%s"
	MessagePrefix    = "MESSAGE#%s"
	ConnectionPrefix = "CONN#%s"
)

type Message struct {
	ConnId    string
	RoomId    string `json:"-" dynamodbav:"PK"`
	CreatedAt string `json:"created_at" dynamodbav:"SK"`
	From      string `json:"from" dynamodbav:"From"`
	Content   string `json:"content" dynamodbav:"Content"`
	TTL       int64  `json:"-" dynamodbav:"TTL"`
}

type ConnectionData struct {
	ConnID      string `json:"-" dynamodbav:"PK"`
	RoomIdEmail string `json:"-" dynamodbav:"SK"`
}
