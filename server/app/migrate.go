package app

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"log"
)

func CreateTable(db *dynamodb.DynamoDB, tableName string) error {
	log.Println("check wheter table exists")
	exists, err := checkTableExists(db, tableName)
	if err != nil {
		return err
	}

	if exists == true {
		log.Println("table exists, no migration needed")
		return nil
	}

	log.Println("table DNE. migrating...")
	_, err = db.CreateTable(&dynamodb.CreateTableInput{
		TableName: aws.String(tableName),
		AttributeDefinitions: []*dynamodb.AttributeDefinition{
			{
				AttributeName: aws.String("id"),
				AttributeType: aws.String("S"),
			},
		},
		KeySchema: []*dynamodb.KeySchemaElement{
			{
				AttributeName: aws.String("id"),
				KeyType:       aws.String("HASH"),
			},
		},
		ProvisionedThroughput: &dynamodb.ProvisionedThroughput{
			ReadCapacityUnits:  aws.Int64(4),
			WriteCapacityUnits: aws.Int64(4),
		},
	})

	if err == nil {
		log.Println("migrating successful")
	}

	if err != nil {
		log.Println("migrating failed")
	}

	return err
}

func checkTableExists(db *dynamodb.DynamoDB, tableName string) (bool, error) {
	_, err := db.DescribeTable(&dynamodb.DescribeTableInput{TableName: aws.String(tableName)})
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			if aerr.Code() == dynamodb.ErrCodeResourceNotFoundException {
				return false, nil
			}
		}

		return false, err
	}
	return true, nil
}
