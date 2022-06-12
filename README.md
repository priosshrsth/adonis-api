## INFO

-----

### Why adonis JS??
No reasons. Main purpose here is to setup a reusable plug and play terraform deployment codebase.

### Goals
1. Create a CI/CD setup that requires minimal changes when using across projects.
2. Try to create a setup where changes needs to be made in a single file for CI/CD

### Pre requisites
1. GCP account with a project setup
2. Gcloud and terraform should be already installed and configured locally.

### Techs Used
1. Makefile
2. Node JS
3. Terraform

## Guides

-----

## Create a service account
  1. Goto https://console.cloud.google.com/iam-admin/iam?project={project_id} and create a new service account
  2. Provide at least following permissions to the service account initially
      1. Storage Object Admin // Storage Admin
      2. Compute Api Engine
      3. Cloud Run Admin
      4. Container Registry Service Agent
      5. Service Account User (*I think this will be available by default*)
  3. [Other options that we might need are](https://cloud.google.com/compute/docs/access/iam):
      1. **Cloud Scheduler Admin** - If we need to run queue
      2. **Compute Admin** - If we need to create/modify instances
      3. **Cloud SQL Admin** - For DB access
  4. Download the credentials.json to local.
     > **Note**: It is very important to add this file to `.gitignore`



 
