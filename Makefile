define GetValueFromJson
   $(shell node ./cicd/read-config.js -p env=$(1) key=$(2))
endef

.PHONY: check-variables create-tf-backend-bucket create-service-account set-role-to-service-account enable-base-services init-gcp-project

## declare variables
PROJECT_ID := $(strip $(call GetValueFromJson, $(ENV), project_id))
PROJECT_NAME := $(strip $(call GetValueFromJson, $(ENV), project_name))
## This will be same as project name for now
SERVICE_ACCOUNT_ID := $(PROJECT_NAME)
STATE_BUCKET := $(strip $(call GetValueFromJson, $(ENV), gcs_state_bucket))
# ------------

# env must be defined to prevent unintentional changes to wrong environment
ifndef ENV
	$(error Please set ENV=[staging|production|*])
endif

# Print variables (Optional- For debugging purpose only)
check-variables:
	@echo ProjectId : $(PROJECT_ID)
	@echo ProjectName : $(PROJECT_NAME)
	@echo StateBucket : $(STATE_BUCKET)
	@echo UserEmail : $(USER_EMAIL)

# Create a bucket. If it already exists, then throws an error
create-tf-backend-bucket:
	- gsutil mb -p $(PROJECT_ID) gs://$(STATE_BUCKET)

# Create a new service account
create-service-account:
	gcloud iam service-accounts create "${SERVICE_ACCOUNT_ID}" \
      --description="${PROJECT_NAME} TF Service Account" \
      --display-name="$(PROJECT_NAME)"

# Provide required role to service account
set-role-to-service-account:
	gcloud projects add-iam-policy-binding ${PROJECT_ID} \
        --member="serviceAccount:${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com" \
        --role="roles/owner"

download-access-key:
	cd cicd && \
		gcloud iam service-accounts keys create access.key.json --iam-account=$(SERVICE_ACCOUNT_ID)@$(PROJECT_ID).iam.gserviceaccount.com

enable-base-services:
	gcloud services enable cloudresourcemanager.googleapis.com serviceusage.googleapis.com

init-gcp-project:
	$(MAKE) create-tf-backend-bucket
	$(MAKE) create-service-account
	$(MAKE) set-role-to-service-account
	$(MAKE) download-access-key
	$(MAKE) enable-base-services

create-tf-workspace:
	cd cicd/terraform && \
		terraform workspace new $(ENV)

terraform-init:
	cd cicd/terraform && \
		terraform workspace select $(ENV) && \
		terraform init


