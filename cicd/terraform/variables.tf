variable "project_name" {
  description = "Project name mainly used to start a project"
  type = string
  nullable = false
}

variable "image_port" {
  description = "The port the image exposes for HTTP requests"
  type        = number
  default     = 3333
}

variable "environment" {
  description = "App Environment: staging | production"
  type = string
  nullable = false
}

variable "project_id" {
  description = "The GCP project id"
  type        = string
  nullable = false
}

variable "client_email" {
  description = "GCP service account"
  type = string
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

variable "gcs_state_bucket" {
  description = "Path for storing state files in gcs bucket"
  type = string
  nullable = false
}

variable "gcs_bucket_prefix" {
  description = "Path for storing state files in gcs bucket"
  type = string
  nullable = false
}

variable "app_image" {
  description = "App image url"
  type = string
  nullable = false
}

variable "app_commit_hash" {
  type = string
}

variable "db_port" {
  type = number
  default = 5400
}

variable "db_password" {
  description = "Database password"
  type = string
  nullable = false
}
