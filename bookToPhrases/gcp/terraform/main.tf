######
# Enable required api
variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default     = [
    "cloudbilling.googleapis.com",
    "eventarc.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "dataflow.googleapis.com",
    "appengine.googleapis.com",
    "bigquery.googleapis.com"
  ]
}
resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project  = var.project
  service  = each.key
}

# Random used to generate a unique name for the resources
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

# Create the storage bucket where books will be stored
resource "google_storage_bucket" "land_area" {
  name          = "${random_id.bucket_prefix.hex}-gilda-land-area"
  location      = var.location
  force_destroy = true

  uniform_bucket_level_access = true

  depends_on = [google_project_service.gcp_services]
}

# Create the storage bucket where all project temporary files will be stored (function sources, dataflow staging, etc)
resource "google_storage_bucket" "temp_bucket" {
  name                        = "${random_id.bucket_prefix.hex}-gilda-temporary"
  location                    = var.location
  uniform_bucket_level_access = true
  depends_on                  = [google_project_service.gcp_services]
}

# Import the notifier module.
# This module creates a cloud function (Nodejs) that will be triggered by the storage bucket
# on file creation. The function will send an email to the specified email address
module "storage_notifier" {
  source = "./modules/storage-notifier"

  storage_name = google_storage_bucket.land_area.name
  location     = google_storage_bucket.land_area.location
  project      = var.project

  sendgrid_api_key = var.sendgrid_api_key
  mail_sender      = var.mail_sender
  mail_receiver    = var.mail_receiver

  storage_temp_name = google_storage_bucket.temp_bucket.name

}

# Import the bigquery_table module.
# This module creates a dataset and a table in BigQuery
module "bigquery_table" {
  source = "./modules/bq-table"

  location = google_storage_bucket.land_area.location
  project  = var.project
}

# Import the dataflow-template module.
# This module creates the json with the dataflow template configuration.
# NOTE: The docker image already exists.
module "dataflow-template" {
  source = "./modules/dataflow-template"

  storage_temp_name    = google_storage_bucket.temp_bucket.name
  dataflow_batch_image = var.dataflow_batch_image

}

# Import the dataflow-job-batch module.
# This module creates a cloud function (Java) that will be triggered by the storage bucket on file creation.
# The function will start a dataflow job that will process the file and store the results in BigQuery
module "dataflow-job-batch" {
  source = "./modules/dataflow-job-batch"

  location = google_storage_bucket.land_area.location
  project  = var.project

  dataflow_template_path = module.dataflow-template.dataflow_template_path

  books_storage_name = google_storage_bucket.land_area.name

  bq_project_id   = var.project
  bq_dataset_name = module.bigquery_table.bq_dataset_name
  bq_table_name   = module.bigquery_table.bq_table_name

  storage_temp_name = google_storage_bucket.temp_bucket.name

}


# Import the AppEngine module.
# This module creates an AppEngine application that will show the content of the BigQuery table
module "app-engine" {
  source = "./modules/app-engine"

  location = google_storage_bucket.land_area.location
  project  = var.project

  app_engine_location     = var.app_engine_location
  app_engine_service_name = var.app_engine_service_name

  bq_project_id           = var.project
  bq_dataset_name         = module.bigquery_table.bq_dataset_name
  bq_table_name           = module.bigquery_table.bq_table_name
  bq_location             = var.location

  storage_temp_name = google_storage_bucket.temp_bucket.name

}
