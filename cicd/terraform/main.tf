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
    prefix = "api"
  }
}

locals {
  environment_variables = {
    APP_ENV              = var.environment
    CLOUD_SQL_CONNECTION = "/cloudsql/${var.project_id}:${var.region}:${google_sql_database_instance.postgres.name}"
    DATABASE_HOST        = google_sql_database_instance.postgres.public_ip_address
    DATABASE_NAME        = google_sql_database.db.name
    DATABASE_PORT        = var.db_port
    DATABASE_USER        = google_sql_user.db.name
    DATABASE_PASSWORD    = google_sql_user.db.password
    STORAGE_DRIVER       = "gcs"
    MEDIA_STORAGE_FOLDER = "/"
  }
}

# cloud run instance

resource "google_cloud_run_service" "app" {
  name = "adonis-api"
  location = var.region
  provider = google-beta
  autogenerate_revision_name = true
  depends_on = [google_sql_database.db]

  template {
    spec {
      containers {
        image = var.app_image

        dynamic "env" {
          for_each = merge(local.environment_variables, { APP_RUNNER: "cloud-run" })
          content {
            name = env.key
            value = env.value
          }
        }

        resources {
          limits = {
            cpu = "1"
            memory = "521Mi"
          }

          requests = {
            cpu = "1"
            memory = "256Mi"
          }
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "1",
        "autoscaling.knative.dev/maxScale" = "10",
        "run.googleapis.com/client-name" = "terraform"
        "run.googleapis.com/cpu-throttling" = false
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.postgres.connection_name
      }
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.app.location
  project = var.project_id
  provider = google-beta
  service = google_cloud_run_service.app.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

# vm worker instance only for running cli commands

module "gce-container" {
  source = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"
  cos_image_name = "cos-85-13310-1366-14"
  depends_on = [google_sql_database.db]

  container = {
    image = var.app_image

    env = [
    for name, value in merge(local.environment_variables, { APP_RUNNER: "vm-instance" }) : {
      name = name
      value = value
    }
    ]
  }

  restart_policy = "Always"
}

resource "google_compute_address" "disposable-vm-static" {
  name = "ipv4-address"
}

# postgres database

resource "google_sql_database_instance" "postgres" {
  name = "${var.project_name}-${var.environment}-postgres"
  database_version = "POSTGRES_14"
  depends_on = [google_compute_address.disposable-vm-static]

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      authorized_networks {
        name  = "disposable-vm"
        value = google_compute_address.disposable-vm-static.address
      }
    }

    backup_configuration {
      enabled = true
      start_time = "02:45"
    }

    database_flags {
      name = "max_connections"
      value = "30"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_sql_user" "db" {
  name = "${var.project_name}-${var.environment}"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}

resource "google_sql_database" "db" {
  name = "${var.project_name}-${var.environment}"
  instance = google_sql_database_instance.postgres.name
  charset = "UTF8"
  collation = "en_US.UTF8"
}

# Cloud Storage

resource "google_storage_bucket" "media" {
  name = "${var.project_name}-media-${var.environment}"
  storage_class = "STANDARD"
  location = var.region
}

resource "google_storage_bucket_access_control" "media_access_roles" {
  bucket = google_storage_bucket.media.name
  role = "WRITER"
  entity = "user-${var.client_email}"
}

resource "google_storage_bucket" "assets" {
  name = "${var.project_name}-assets-${var.environment}"
  storage_class = "STANDARD"
  location = var.region
}

resource "google_storage_bucket_access_control" "assets_access_roles" {
  bucket = google_storage_bucket.assets.name
  role   = "READER"
  entity = "allUsers"
}

# Cloud Scheduler

resource "google_cloud_scheduler_job" "activities_place_details_sync" {
  name = "adonis-api-activities_place_details_sync"
  description = "Pings activities/place-details-sync at minute 0"
  schedule = "0 * * * *"
  region = "us-central1"
  time_zone = "GMT"
  http_target {
    http_method = "POST"
    uri = "${google_cloud_run_service.app.status[0].url}/activities/place-details-sync"
  }
}
