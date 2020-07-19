package app

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/brietsparks/guestbook-server/lib"
	"time"
)

type Item struct {
	Id    string `json:"id",dynamodbav:"id"`
	Value string `json:"value",dynamodbav:"value"`
	Ts    int32  `json:"ts",dynamodbav:"ts"`
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

func (m *Model) CreateItem(value string) (*Item, error) {
	item := Item{
		Id:    lib.RandString(12),
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

func (m *Model) GetItem(id string) (*Item, error) {
	result, err := m.db.GetItem(&dynamodb.GetItemInput{
		TableName: aws.String(m.tableName),
		Key: map[string]*dynamodb.AttributeValue{
			"id": { S: aws.String(id) },
		},
	})
	if err != nil {
		return nil, err
	}

	item := &Item{}
	err = dynamodbattribute.UnmarshalMap(result.Item, item)
	if err != nil {
		return nil, err
	}

	if item.Id == "" {
		return nil, nil
	}

	return item, nil
}
