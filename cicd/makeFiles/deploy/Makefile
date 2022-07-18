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
