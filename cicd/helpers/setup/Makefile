# Print variables (Optional- For debugging purpose only)
check-variables:
	@echo ProjectId : $(PROJECT_ID)
	@echo ProjectName : $(PROJECT_NAME)
	@echo StateBucket : $(STATE_BUCKET)
	@echo CommitHash : $(COMMIT_HASH)
	@echo ProjectDir : $(PROJECT_DIR)

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
	cd cicd/credentials && \
		gcloud iam service-accounts keys create $(firstword $(subst :, ,$(ENV))).key.json --iam-account=$(SERVICE_ACCOUNT_ID)@$(PROJECT_ID).iam.gserviceaccount.com

enable-base-services:
	gcloud services enable cloudresourcemanager.googleapis.com serviceusage.googleapis.com

configure-gcp-project:
	$(MAKE) create-tf-backend-bucket
	$(MAKE) create-service-account
	$(MAKE) set-role-to-service-account
	$(MAKE) download-access-key
	$(MAKE) enable-base-services
