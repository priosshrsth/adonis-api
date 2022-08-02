include .env

define GetValueFromJson
   $(shell node ./cicd/helpers/read-config.js -p env=$(firstword $(subst :, ,$(ENV))) key=$(firstword $(subst :, ,$(1))))
endef

.PHONY: all check-variables create-tf-backend-bucket create-service-account set-role-to-service-account enable-base-services init-gcp-project

pre-build:
    ifndef ENV
    	$(error "Please set ENV=[staging|production] before `make command_name`")
    endif

## declare variables
PROJECT_ID := $(strip $(call GetValueFromJson, project_id))
PROJECT_NAME := $(strip $(call GetValueFromJson, project_name))
## This will be same as project name for now
SERVICE_ACCOUNT_ID := $(PROJECT_NAME)
STATE_BUCKET := $(strip $(call GetValueFromJson, gcs_state_bucket))
# ------------

# This will export all variables from this make file to sub make files
export

check-variables:
	$(MAKE) -f ./cicd/helpers/setup/Makefile check-variables

configure-gcp-project:
	$(MAKE) -f cicd/helpers/setup/Makefile configure-gcp-project

