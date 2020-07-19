package main

import (
	"github.com/brietsparks/guestbook-server/app"
	"github.com/brietsparks/guestbook-server/lib"
	"log"
)

func main() {
	serverPort := lib.RequireVar("SERVER_PORT")
	dynamoTable := lib.RequireVar("DYNAMO_TABLE")
	region := lib.RequireVar("AWS_REGION")

	a, err := app.NewApp(app.Args{
		DynamoTable: dynamoTable,
		Region: region,
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
