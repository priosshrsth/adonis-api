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


# App configs

variable "db_port" {
  type = number
  default = 5400
}

variable "db_password" {
  description = "Database password"
  type = string
  nullable = false
}

## Variables for env files
# remove this if not required
variable "app_name" {
  description = "Name of the app"
  default = "Adonis API"
}

variable "app_port" {
  description = "port where app runs"
#  Set default based on your app/tech used. For adonis it is 3333
  default = "3333"
}

variable "app_host" {
  description = "host where app runs eg: 0.0.0.0"
  default = "0.0.0.0"
}

# remove this if not required
variable "app_key" {
  description = "Unique key usually required for apis"
}

variable "drive_disk" {
  description = "required for adonis for asset storage"
  default = "local"
}
