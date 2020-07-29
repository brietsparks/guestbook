package app

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/brietsparks/guestbook-server/lib"
)

type Args struct {
	DynamoTable string
	Region      string
	ClientOrigin 		string
}

type App struct {
	Db      *dynamodb.DynamoDB
	Model   *Model
	Serve   func(string) error
	Migrate func() error
}

func NewApp(args Args) (*App, error) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(args.Region),
	})
	if err != nil {
		return nil, err
	}

	db := dynamodb.New(sess)
	migrate := func() error { return CreateTable(db, args.DynamoTable) }
	model := NewModel(db, args.DynamoTable)
	serve := func(port string) error {
		return Serve(model, port, lib.DefaultLogger, args.ClientOrigin)
	}

	return &App{
		Db:      db,
		Migrate: migrate,
		Model:   model,
		Serve:   serve,
	}, nil
}

