# Random used to generate a unique name for the resources
resource "random_id" "rnd" {
  byte_length = 4
}

# Create a secret in Secret Manager with the SendGrid API key
# This is a sensitive value that should not be stored in plain text
resource "google_secret_manager_secret" "sendgrid_apikey" {
  secret_id = "TERRAFORM_SENDGRID_API_KEY"
  project   = var.project

  replication {
    auto {}
  }
}
# Define the value of the secret
resource "google_secret_manager_secret_version" "sendgrid_apikey" {
  secret = google_secret_manager_secret.sendgrid_apikey.id

  secret_data = var.sendgrid_api_key
}

# Store the zip archive in a global temporary GCS bucket
data "archive_file" "fn_src" {
  type        = "zip"
  output_path = "notifier-function-source.zip"
  source_dir  = "modules/storage-notifier/function-source/"
}

# Store the zip archive in a global temporary GCS bucket
resource "google_storage_bucket_object" "fn_src_bucket_object" {
  name   = "storage-notifier/fn-src/notifier-function-source.zip"
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

# Create the service account used by the function and Eventarc trigger
resource "google_service_account" "account" {
  account_id   = "notifier-sa"
  display_name = "Test Service Account - used for both the cloud function and eventarc trigger"
}

locals {
  # Roles to be assigned to the notifier service account
  fn_roles = [
    "roles/run.invoker", # Required to invoke the Cloud Function
    "roles/eventarc.eventReceiver", # Required to receive events from Eventarc
    "roles/artifactregistry.reader", # Required to read from Artifact Registry
    "roles/secretmanager.secretAccessor", # Required to read the SendGrid API key from Secret Manager
  ]
}
# # Assign the roles to the runner service accounts
resource "google_project_iam_member" "role" {
  for_each   = toset(local.fn_roles)
  project    = var.project
  role       = each.value
  member     = "serviceAccount:${google_service_account.account.email}"
#   depends_on = [google_project_iam_member.gcs_pubsub_publishing]
}

# Create the cloud function
resource "google_cloudfunctions2_function" "fn" {
  depends_on = [
    google_project_iam_member.role
  ]
  name        = "notifier-${random_id.rnd.hex}"
  location    = lower(var.location)
  description = "Notifier function"

  build_config {

    runtime     = "nodejs20"
    entry_point = "helloGCS"
    source {
      storage_source {
        bucket = var.storage_temp_name
        object = google_storage_bucket_object.fn_src_bucket_object.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    min_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60

    environment_variables = {
      MAIL_RECEIVER = var.mail_receiver
      MAIL_SENDER   = var.mail_sender
    }

    # Get sendgrid api key from the secret manager
    secret_environment_variables {
      key        = "SENDGRID_API_KEY"
      project_id = var.project
      secret     = google_secret_manager_secret.sendgrid_apikey.secret_id
      version    = google_secret_manager_secret_version.sendgrid_apikey.version
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.account.email
  }

  event_trigger {
    trigger_region = lower(var.location) # The trigger must be in the same location as the bucket
    event_type            = "google.cloud.storage.object.v1.finalized"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.account.email
    event_filters {
      attribute = "bucket"
      value     = var.storage_name
    }
  }
}
