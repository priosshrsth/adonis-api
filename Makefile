include .env

define GetValueFromJson
   $(shell node ./cicd/read-config.js -p env=$(firstword $(subst :, ,$(1))) key=$(firstword $(subst :, ,$(2))))
endef



.PHONY: all check-variables create-tf-backend-bucket create-service-account set-role-to-service-account enable-base-services init-gcp-project

pre-build:
    ifndef ENV
    	$(error "Please set ENV=[staging|production] before `make command_name`")
    endif	ifndef ENV


## declare variables
PROJECT_ID := $(strip $(call GetValueFromJson, $(ENV), project_id))
PROJECT_NAME := $(strip $(call GetValueFromJson, $(ENV), project_name))
## This will be same as project name for now
SERVICE_ACCOUNT_ID := $(PROJECT_NAME)
STATE_BUCKET := $(strip $(call GetValueFromJson, $(ENV), gcs_state_bucket))
# ------------

# This will export all variables from this make file to sub make files
export

default:
	$(MAKE) -f cicd/makeFiles/setup/Makefile check-variables

configure-gcp-project:
	$(MAKE) -f cicd/makeFiles/setup/Makefile configure-gcp-project

terraform-apply:
	cd ./cicd/terraform && \
		terraform apply \
		-var-file="./environments/$(ENV).tfvars.json"
