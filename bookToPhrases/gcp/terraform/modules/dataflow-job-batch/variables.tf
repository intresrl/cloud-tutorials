variable "project" {
  type        = string
  description = "Project id"
}

variable "location" {
  type        = string
  default     = "europe-west8"
  description = "Location"
}

variable "storage_temp_name" {
  type        = string
  description = "Storage used for temp files (builds/staging etc)"
}

variable "books_storage_name" {
  type        = string
  description = "Storage name for books"
}


variable "dataflow_template_path" {
  type        = string
  description = "Name of the storage that contains the dataflow template"
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

variable "docker_image" {
  type        = string
  default     = "th3nu11/dataflow-booktophrases:v3"
  description = "Dataflow template docker image"
}