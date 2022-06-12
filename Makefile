define GetValueFromJson
   $(shell node ./cicd/read-config.js -p env=$(1) key=$(2))
endef

PROJECT_ID := $(strip $(call GetValueFromJson, $(ENV), project_id))
PROJECT_NAME := $(strip $(call GetValueFromJson, $(ENV), project_name))
STATE_BUCKET := $(strip $(call GetValueFromJson, $(ENV), gcs_state_bucket))

ifndef ENV
	$(error Please set ENV=[staging|production|*])
endif

check-variables:
	@echo ProjectId : $(PROJECT_ID)
	@echo ProjectName : $(PROJECT_NAME)
	@echo StateBucket : $(STATE_BUCKET)


create-tf-backend-bucket:
	gsutil mb -p $(PROJECT_ID) gs://$(STATE_BUCKET)

create-tf-workspace:
	cd cicd/terraform && \
		terraform workspace new $(ENV)

terraform-init:
	cd cicd/terraform && \
		terraform workspace select $(ENV) && \
		terraform init


