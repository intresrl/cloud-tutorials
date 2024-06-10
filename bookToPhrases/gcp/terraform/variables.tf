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

variable "sendgrid_api_key" {
  type        = string
  description = "send grid api key"
}

variable "mail_sender" {
  type        = string
  description = "mail sender (Configured in sendgrid)"
}

variable "mail_receiver" {
  type        = string
  description = "mail receiver"
}

variable "dataflow_batch_image" {
  type        = string
  default     = "th3nu11/dataflow-booktophrases:v3"
  description = "dataflow flex template docker image"
}