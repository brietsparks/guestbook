package lib

import (
	"log"
	"os"
)

func RequireVar(name string) string {
	value := os.Getenv(name)
	if value == "" {
		log.Fatalf("missing environment variable %s", name)
	}
	return value
}
