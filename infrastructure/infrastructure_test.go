package main

import (
	"fmt"
	httpHelper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"log"
	"os/exec"
	"strings"
	"testing"
	"time"
)

func TestInfrastructure(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: ".",
		VarFiles: []string{"./dev.tfvars"},
	}

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	albDnsHost := terraform.Output(t, terraformOptions, "alb_dns_host")

	time.Sleep(90 * time.Second)

	// Verify the page loads and the app runs
	httpHelper.HttpGetWithRetryWithCustomValidation(t, albDnsHost, nil, 30, 5*time.Second,
		func(status int, body string) bool {
			if status != 200 {
				return false
			}

			fmt.Println("Running Cypress tests...")
			err := runCypressTests(albDnsHost)
			if err != nil {
				log.Print(err)
				return false
			}

			return true
		},
	)
}

func runCypressTests(url string) error {
	cmdStr := fmt.Sprintf("npm run test -- --env URL=\"%s\"", url)
	parts := strings.Fields(cmdStr)
	cmd := exec.Command(parts[0], parts[1:]...)
	cmd.Dir = "../test"
	_, err := cmd.Output()
	return err
}
