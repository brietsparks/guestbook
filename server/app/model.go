package app

import (
	"errors"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"net"
	"time"
)

type Item struct {
	Ip    string `json:"ip",dynamodbav:"ip"`
	Ts    int32  `json:"ts",dynamodbav:"ts"`
	Value string `json:"value",dynamodbav:"value"`
}

type Model struct {
	db        *dynamodb.DynamoDB
	tableName string
}

func NewModel(db *dynamodb.DynamoDB, tableName string) *Model {
	return &Model{
		db:        db,
		tableName: tableName,
	}
}

func (m *Model) Ping() bool {
	return true
}

func (m *Model) CreateItem(ip string, value string) (*Item, error) {
	if !isIpv4(ip) {
		return nil, errors.New("invalid ip")
	}

	item := Item{
		Ip:    ip,
		Value: value,
		Ts:    int32(time.Now().Unix()),
	}

	av, err := dynamodbattribute.MarshalMap(item)
	if err != nil {
		return nil, err
	}
	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String(m.tableName),
	}

	_, err =  m.db.PutItem(input)
	return &item, err
}

func (m *Model) GetItemsByIp(ip string, limit int64) (*[]Item, error) {
	if !isIpv4(ip) {
		return nil, errors.New("invalid ip")
	}

	input := &dynamodb.QueryInput{
		TableName: aws.String(m.tableName),
		KeyConditions: map[string]*dynamodb.Condition{
			"ip": {
				ComparisonOperator: aws.String("EQ"),
				AttributeValueList: []*dynamodb.AttributeValue{
					{ S: aws.String(ip) },
				},
			},
		},
		ScanIndexForward: aws.Bool(false),
		Limit: aws.Int64(limit),
	}

	result, err :=  m.db.Query(input)
	if err != nil {
		return nil, err
	}

	items := &[]Item{}
	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, items)
	if err != nil {
		return nil, err
	}

	return items, nil
}

func isIpv4(host string) bool {
	return net.ParseIP(host) != nil
}
