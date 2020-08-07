current_dir = $(shell pwd)
prod_env := infrastructure/environments/prod
test_env := infrastructure/environments/test
dev_env := infrastructure/environments/dev
test_runner := infrastructure/test

$(prod_env)/.terraform:
	cd ./$(prod_env); terraform init

$(test_env)/.terraform:
	cd ./$(test_env); terraform init

$(dev_env)/.terraform:
	cd ./$(dev_env); terraform init

client/node_modules:
	cd ./client; yarn

.PHONY: prod
prod: $(prod_env)/.terraform
	cd ./$(prod_env); \
 		terraform apply -var-file=$(current_dir)/$(var-file)

.PHONY: prod-down
prod-down: $(prod_env)/.terraform client/node_modules
	cd ./$(prod_env); \
 		terraform destroy -var-file=$(current_dir)/$(var-file)

.PHONY: test
test: $(test_env)/.terraform
	cd ./$(test_runner); \
		export VAR_FILE=$(current_dir)/$(var-file); \
		go test -v -run TestInfrastructure -timeout 15m

.PHONY: dev
dev: $(dev_env)/.terraform
	cd ./$(dev_env); \
		terraform apply -var-file=$(current_dir)/$(var-file)

.PHONY: dev-down
dev-down: $(dev_env)/.terraform
	cd ./$(dev_env); \
		terraform destroy -var-file=$(current_dir)/$(var-file)
