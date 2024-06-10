# Random used to generate a unique name for the resources
resource "random_id" "rnd" {
  byte_length = 4
}

# Store the zip archive in a global temporary GCS bucket
data "archive_file" "fn_src" {
  type        = "zip"
  output_path = "app-engine-source.zip"
  source_dir  = "modules/app-engine/source/"
}

# Store the zip archive in a global temporary GCS bucket
resource "google_storage_bucket_object" "fn_src_bucket_object" {
  name   = "app-engine/fn-src/app-engine-source.zip"
  bucket = var.storage_temp_name
  source = data.archive_file.fn_src.output_path # Path to the zipped function source code
}

# Create the service account used by the function and Eventarc trigger
resource "google_service_account" "account" {
  account_id   = "app-engine-sa"
  display_name = "App Engine Service Account"
}

locals {
  # Roles to be assigned to the notifier service account
  fn_roles = [
    "roles/bigquery.dataViewer",
    "roles/bigquery.jobUser"

  ]
}
# # Assign the roles to the runner service accounts
resource "google_project_iam_member" "role" {
  for_each = toset(local.fn_roles)
  project  = var.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.account.email}"
  #   depends_on = [google_project_iam_member.gcs_pubsub_publishing]
}

# Create app engine
resource "google_app_engine_application" "app" {
  project = var.project
  location_id = var.app_engine_location
}

# Create the app engine version
resource "google_app_engine_standard_app_version" "app_v1" {
  depends_on = [google_app_engine_application.app]
  version_id = "v1"
  service    = "default"
  runtime    = "nodejs20"

  entrypoint {
    shell = "node ./server.js"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${var.storage_temp_name}/${google_storage_bucket_object.fn_src_bucket_object.name}"
    }
  }
  service_account = google_service_account.account.email
  env_variables = {
    PROJECT_ID = var.bq_project_id
    DATASET_ID = var.bq_dataset_name
    TABLE_ID   = var.bq_table_name
    LOCATION   = var.bq_location
  }

  automatic_scaling {
    max_concurrent_requests = 10
    min_idle_instances      = 1
    max_idle_instances      = 3
    min_pending_latency     = "1s"
    max_pending_latency     = "5s"

    standard_scheduler_settings {
      target_cpu_utilization        = 0.5
      target_throughput_utilization = 0.75
      min_instances                 = 0
      max_instances                 = 5
    }
  }

  delete_service_on_destroy = true
}