variable "project_name" {
  description = "Project name mainly used to start a project"
  type = string
}

variable "project_id" {
  description = "The GCP project id"
  type        = string
  nullable = false
}

variable "region" {
  description = "GCP region"
  type        = string
  nullable = false
}

variable "zone" {
  description = "GCP zone"
  type = string
  nullable = false
}

#variable "app_image" {
#  description = "Url from google container repository image"
#  type = string
#}

variable "gcs_state_bucket" {
  description = "Path for storing state files in gcs bucket"
  type = string
}

variable "gcs_bucket_prefix" {
  description = "Path for storing state files in gcs bucket"
  type = string
}
