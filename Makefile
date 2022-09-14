-include .env

# This host is used to proxy google cloud sql server.
#In case our app is dockerized we could provide ip assigned to our device to use the specific server locally through this
HOST ?= 127.0.0.1

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
COMMIT_HASH := $(shell git rev-parse --short HEAD)
APP_IMAGE := gcr.io/$(PROJECT_ID)/$(PROJECT_NAME):$(COMMIT_HASH)
SERVICE_ACCOUNT_EMAIL :=$(SERVICE_ACCOUNT_ID)@$(PROJECT_ID).iam.gserviceaccount.com
PROJECT_DIR := $(shell pwd)
# ------------

# This will export all variables from this make file to sub make files
export

check-variables:
	$(MAKE) -f ./cicd/helpers/setup/Makefile check-variables

configure-gcp-project:
	$(MAKE) -f cicd/helpers/setup/Makefile configure-gcp-project

set-role-to-service-account:
	$(MAKE) -f cicd/helpers/setup/Makefile set-role-to-service-account

configure-gcp-project:
	$(MAKE) -f cicd/helpers/setup/Makefile configure-gcp-project

create-tf-workspace:
	$(MAKE) -f cicd/helpers/deploy/Makefile create-tf-workspace

terraform-init:
	$(MAKE) -f cicd/helpers/deploy/Makefile terraform-init

terraform-apply:
	$(MAKE) -f cicd/helpers/deploy/Makefile terraform-apply

build-docker-image:
	$(MAKE) -f cicd/helpers/deploy/Makefile build-docker-image

push-new-image:
	$(MAKE) -f cicd/helpers/deploy/Makefile authenticate-docker
	$(MAKE) -f cicd/helpers/deploy/Makefile build-docker-image
	$(MAKE) -f cicd/helpers/deploy/Makefile push-docker-image


encrypt-environment-secrets:
	cd cicd/terraform && gpg --symmetric --batch --yes --passphrase ${PASSPHRASE} --cipher-algo AES256 ${ENV}.secret.tfvars && \
		gpg --symmetric --batch --yes --passphrase ${PASSPHRASE} --cipher-algo AES256 terraform.secret.tfvars

decrypt-environment-secrets:
	cd cicd/terraform && gpg --quiet --batch --yes --decrypt --passphrase ${PASSPHRASE} --cipher-algo AES256 --output "${ENV}.secret.tfvars" "${ENV}.secret.tfvars.gpg" && \
		gpg --quiet --batch --yes --decrypt --passphrase ${PASSPHRASE} --cipher-algo AES256 --output "terraform.secret.tfvars" "terraform.secret.tfvars.gpg" \

encrypt-service-account:
	cd cicd/credentials && gpg --symmetric --batch --yes --passphrase ${PASSPHRASE} --cipher-algo AES256 ${ENV}.key.json

decrypt-service-account:
	cd cicd/credentials && gpg --quiet --batch --yes --decrypt --passphrase ${PASSPHRASE} --cipher-algo AES256 --output "${ENV}.key.json" "${ENV}.key.json.gpg"

encrypt-data:
	$(MAKE) encrypt-environment-secrets
	$(MAKE) encrypt-service-account

decrypt-data:
	$(MAKE) decrypt-environment-secrets
	$(MAKE) decrypt-service-account

# TODO:- need to change the value from folio DB
proxy_staging_cloud_sql:
	cd cicd/credentials && cloud_sql_proxy -instances=folio-staging-333109:us-central1:folio-api-staging-postgres=tcp:${HOST}:5433 -credential_file=./staging-service-account.json

# TODO:- need to change the value from folio DB
proxy_production_cloud_sql:
	cd cicd/credentials && cloud_sql_proxy -instances=folio-production-333109:us-central1:folio-api-production-postgres=tcp:${HOST}:5400 -credential_file=./production-service-account.json

proxy_cloud_sql:
	$(MAKE) proxy_${ENV}_cloud_sql


trigger-deploy:
#We could get the current branch as well. But could be un-intentional
ifndef BRANCH
	$(error "Please provide appropriate branch name to deploy")
endif
	curl \
      -X POST  \
      -H 'Accept: application/vnd.github.everest-preview+json' \
      -H "Authorization: token ${GITHUB_DEPLOY_TOKEN}" \
      https://api.github.com/repos/priosshrsth/adonis-api/dispatches \
      --data '{"event_type": "deploy-service", "client_payload": {"environment": "'"${ENV}"'", "ref": "'"${BRANCH}"'"}}' \
