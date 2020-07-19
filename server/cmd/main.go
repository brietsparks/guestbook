package main

import (
	"github.com/brietsparks/guestbook-server/app"
	"github.com/brietsparks/guestbook-server/lib"
	"log"
)

func main() {
	region := lib.RequireVar("REGION")
	dynamoEndpoint := lib.RequireVar("DYNAMO_ENDPOINT")
	dynamoTable := lib.RequireVar("DYNAMO_TABLE")
	keyId := lib.RequireVar("KEY_ID")
	keySecret := lib.RequireVar("KEY_SECRET")
	serverPort := lib.RequireVar("SERVER_PORT")

	a, err := app.NewApp(app.Args{
		Region: region,
		DynamoEndpoint: dynamoEndpoint,
		DynamoTable: dynamoTable,
		KeyId: keyId,
		KeySecret: keySecret,
	})
	if err != nil {
		log.Fatalf("failed to create app: %s", err)
	}

	err = a.Migrate()
	if err != nil {
		log.Fatal(err)
	}

	err = a.Serve(serverPort)

	log.Fatalf("failed to serve: %s", err)
}
