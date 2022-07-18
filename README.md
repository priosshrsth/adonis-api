## INFO

-----
### Good Reads
1. https://genekuo.medium.com/setting-up-a-ci-cd-pipeline-on-gcp-with-terraform-539e66797072
2. https://cloud.google.com/storage/docs/creating-buckets#prereq-cli
3. https://cloud.google.com/sdk/gcloud/reference/iam/roles
4. https://cloud.google.com/compute/docs/access/iam#compute.instanceAdmin

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

## config.json
This is the most important file. Every configuration goes in this file.

```json
{
   
  "common": "Place for all common variables across the environments",
  "production": {},
  "staging": {}  
}
```

-----
### Create a project
A pre-existing project is required. This project id needs to be copied in our config.json file.
If we need multiple projects for each environment, then it can go to enivronment block in config.json file.
Otherwise, we can add it to common.json

### Add a billing account to the project


### [Create a service account](https://console.cloud.google.com/iam-admin/serviceaccounts?project={project_id)
```bash
ENV={production|staging} configure-gcp-project
```
This will create a service account, set it as owner, download keys and save it to `cicd/access.key.json`
If it throws error, then service account must already exist in the project. In which case, you can choose to 
configure roles manually in gcp console or via makefile.

### Configure service account in project in gcp console manually. (If not done automatically by above command)
1. Provide at least following permissions to the service account initially
      1. Storage Object Admin // Storage Admin
      2. Compute Api Engine
      3. Cloud Run Admin
      4. Container Registry Service Agent
      5. Service Account User (*I think this will be available by default*)
2. [Other options that we might need are](https://cloud.google.com/compute/docs/access/iam):
    1. **Cloud Scheduler Admin** - If we need to run queue
    2. **Compute Admin** - If we need to create/modify instances
    3. **Cloud SQL Admin** - For DB access
3. [Allow user to impersonate the service account](https://cloud.google.com/iam/docs/impersonating-service-accounts#allow-impersonation)
4. Download the credentials.json to local.
     > **Note**: It is very important to add this file to `.gitignore`



 
