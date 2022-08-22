pre-build:
	ifndef ENV
		$(error "Please set ENV=[staging|production|*] before `make command_name`")
	endif

create-tf-workspace:
	cd cicd/terraform && \
		terraform workspace new $(ENV)

terraform-init:
	cd cicd/terraform && \
    GOOGLE_APPLICATION_CREDENTIALS=$(PROJECT_DIR)/cicd/credentials/$(ENV).key.json \
		terraform init -backend-config bucket="$(STATE_BUCKET)"

terraform-apply:
	cd ./cicd/terraform && \
    GOOGLE_APPLICATION_CREDENTIALS=$(PROJECT_DIR)/cicd/credentials/$(ENV).key.json \
		terraform apply \
		-var-file="../../gcp-config/common.json" \
		-var-file="../../gcp-config/$(ENV).json" \
		-var-file="../../terraform/terraform.tfvars" \
		-var-file="../../terraform/terraform.secret.tfvars" \
		-var-file="../../terraform/$(ENV).tfvars" \
		-var-file="../../terraform/$(ENV).secret.tfvars" \
		app_commit_hash=$(COMMIT_HASH)
		-auto-approve
