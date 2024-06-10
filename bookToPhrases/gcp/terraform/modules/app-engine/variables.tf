variable "project" {
  type        = string
  description = "Project id"
}

variable "location" {
  type        = string
  default     = "europe-west8"
  description = "Location"
}

variable "app_engine_location" {
  type        = string
  default     = "europe-west6"
  description = "Location of the app engine service (check the availability before edit)"
}

variable "app_engine_service_name" {
  type        = string
  default     = "default"
  description = "Name of app engine service. First service MUST be named 'default'"
}

variable "storage_temp_name" {
  type        = string
  description = "Storage used for temp files (builds/staging etc)"
}

variable "bq_project_id" {
  type        = string
  description = "bigquery project id"
}

variable "bq_dataset_name" {
  type        = string
  description = "bigquery dataset name"
}

variable "bq_table_name" {
  type        = string
  description = "bigquery table name"
}

variable "bq_location" {
  type        = string
  description = "bigquery location"
}