pre-build:
	ifndef ENV
		$(error "Please set ENV=[staging|production|*] before `make command_name`")
	endif

CICD_DIR := $(PROJECT_DIR)/cicd/

create-tf-workspace:
	cd cicd/terraform && \
		terraform workspace new $(ENV)

terraform-init:
	cd cicd/terraform && \
    GOOGLE_APPLICATION_CREDENTIALS="$(PROJECT_DIR)/cicd/credentials/$(ENV).key.json" \
		terraform init -backend-config bucket="$(STATE_BUCKET)"

authenticate-docker:
	gcloud auth activate-service-account "${SERVICE_ACCOUNT_EMAIL}" \
		--key-file="${CICD_DIR}credentials/$(ENV).key.json"
	gcloud auth configure-docker gcr.io --quiet

build-docker-image:
	docker build -t "${APP_IMAGE}" --target production -f Dockerfile "${PROJECT_DIR}"

push-docker-image:
	docker push "${APP_IMAGE}"

terraform-apply:
	cd ./cicd/terraform && \
		GOOGLE_APPLICATION_CREDENTIALS="$(PROJECT_DIR)/cicd/credentials/$(ENV).key.json" \
		terraform apply \
		-var app_image="${APP_IMAGE}" \
		-var app_commit_hash="${COMMIT_HASH}" \
		-var client_email="${SERVICE_ACCOUNT_EMAIL}" \
		-var-file="${CICD_DIR}gcp-config/common.json" \
		-var-file="${CICD_DIR}gcp-config/$(ENV).json" \
		-var-file="${CICD_DIR}terraform/terraform.tfvars" \
		-var-file="${CICD_DIR}terraform/terraform.secret.tfvars" \
		-var-file="${CICD_DIR}terraform/$(ENV).tfvars" \
		-var-file="${CICD_DIR}terraform/$(ENV).secret.tfvars" \
		-auto-approve
