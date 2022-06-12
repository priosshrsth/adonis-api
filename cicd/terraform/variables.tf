variable "project_id" {
  default = "playground-325915"
  description = "The GCP project id"
  type        = string
}

variable "region" {
  default     = "us-central1"
  description = "GCP region"
  type        = string
}

variable "zone" {
  default = "use-central1-c"
  description = "GCP zone"
  type = string
}

variable "app_image" {
  description = "Url from google container repository image"
  type = string
}

variable "gcs_bucket_prefix" {
  description = "Path for storing state files in gcs bucket"
  type = string
}
