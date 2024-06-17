# Random used to generate a unique name for the resources
resource "random_id" "rnd" {
  byte_length = 8
}

# Create zip archive of the function source code
data "archive_file" "fn_src" {
  type        = "zip"
  output_path = "dataflow-runner-fn-source.zip"
  source_dir  = "modules/dataflow-job-batch/dataflow-job-runner-fn-source/"
}

# Store the zip archive in a global temporary GCS bucket
resource "google_storage_bucket_object" "fn_src_bucket_object" {
  name   = "dataflow-job-batch/fn-src/dataflow-runner-fn-source.zip"
  bucket = var.storage_temp_name
  source = data.archive_file.fn_src.output_path # Path to the zipped function source code
}

data "google_storage_project_service_account" "default" {
}

# To use GCS CloudEvent triggers, the GCS service account requires the Pub/Sub Publisher(roles/pubsub.publisher) IAM role in the specified project.
# (See https://cloud.google.com/eventarc/docs/run/quickstart-storage#before-you-begin)

resource "google_project_iam_member" "gcs_pubsub_publishing" {
  project = var.project
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.default.email_address}"
}

# Create the service account used by the cloud function to run the dataflow job
resource "google_service_account" "runner" {
  account_id   = "dataflow-runner-sa"
  display_name = "Account used by the cloud function to run the dataflow job"
}

# Create the service account used by the dataflow job to read file from bucket and write to BigQuery
resource "google_service_account" "dataflow" {
  account_id   = "dataflow-sa"
  display_name = "Account used by the dataflow job to read file from bucket and write to BigQuery"
}

# Allow the runner service account (dataflow-runner-sa) to impersonate the dataflow service account (dataflow-sa)
resource "google_service_account_iam_member" "admin-account-iam" {
  service_account_id = google_service_account.dataflow.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.runner.email}"
}

locals {
  # Roles to be assigned to the runner service account
  runner_roles = [
    "roles/run.invoker",
    "roles/eventarc.eventReceiver",
    "roles/artifactregistry.reader",
    "roles/dataflow.admin",
    "roles/storage.objectUser",
    "roles/storage.admin"
  ]
  # Roles to be assigned to the dataflow service account
  dataflow_roles = [
    "roles/artifactregistry.reader",
    "roles/dataflow.worker",
    "roles/bigquery.dataEditor",
    "roles/storage.objectUser"
  ]
}
# Assign the roles to the runner service accounts
resource "google_project_iam_member" "runner_roles" {
  for_each = toset(local.runner_roles)
  project  = var.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.runner.email}"
  #   depends_on = [google_project_iam_member.gcs_pubsub_publishing]
}
# Assign the roles to the dataflow service accounts
resource "google_project_iam_member" "dataflow_roles" {
  for_each = toset(local.dataflow_roles)
  project  = var.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.dataflow.email}"
  #   depends_on = [google_project_iam_member.gcs_pubsub_publishing]
}

# Create the cloud function
resource "google_cloudfunctions2_function" "runner_fn" {
  depends_on = [
    google_project_iam_member.runner_roles,
    google_project_iam_member.dataflow_roles
  ]
  name        = "dataflow-runner-${random_id.rnd.hex}"
  location    = lower(var.location)
  description = "Dataflow job runner"

  build_config {

    runtime     = "java11"
    entry_point = "it.intre.booktophrases.dataflowrunner.DataFlowRunner"

    source {
      storage_source {
        bucket = var.storage_temp_name
        object = google_storage_bucket_object.fn_src_bucket_object.name
      }
    }
  }

  service_config {
    max_instance_count = 5
    min_instance_count = 0
    available_memory   = "256M"
    timeout_seconds    = 60

    environment_variables = {
      PROJECT_ID                 = var.project
      LOCATION                   = lower(var.location)
      DATAFLOW_TEMPLATE_GCS_PATH = var.dataflow_template_path
      BIGQUERY_PROJECT_ID        = var.bq_project_id
      BIGQUERY_DATASET_NAME      = var.bq_dataset_name
      BIGQUERY_TABLE_NAME        = var.bq_table_name
      DATAFLOW_SERVICE_ACCOUNT   = google_service_account.dataflow.email
      STAGING_LOCATION           = "gs://${var.storage_temp_name}/dataflow-job-batch/dataflow-staging"
    }

    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.runner.email
  }

  event_trigger {
    trigger_region = lower(var.location) # The trigger must be in the same location as the bucket
    event_type            = "google.cloud.storage.object.v1.finalized"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.runner.email
    event_filters {
      attribute = "bucket"
      value     = var.books_storage_name
    }
  }
}
