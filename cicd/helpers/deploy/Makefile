pre-build:
	ifndef ENV
		$(error "Please set ENV=[staging|production|*] before `make command_name`")
	endif

create-tf-workspace:
	cd cicd/terraform && \
		terraform workspace new $(ENV)

terraform-init:
	cd cicd/terraform && \
		terraform workspace select $(ENV) && \
		terraform init

terraform-apply:
	cd ./cicd/terraform && \
			terraform apply \
			-var-file="../credentials/$(ENV).key.json"
			-var-file="./terraform.secret.tfvars"
			-var-file="./$(ENV).tfvars"
			-var-file="./$(ENV).secret.tfvars"
