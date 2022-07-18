provider "google" {
  project = var.project_id
  region = var.region
  zone = var.zone
}

provider "google-beta" {
  project = var.project_id
  region = var.region
  zone = var.zone
}

terraform {
  backend "gcs" {
    bucket = ""
    prefix = var.gcs_bucket_prefix
  }
}


#output "show_locals" {
#  value = var.gcs_state_bucket
#}
