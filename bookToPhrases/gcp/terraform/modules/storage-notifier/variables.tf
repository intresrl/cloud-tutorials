variable "project" {
  type        = string
  description = "Project id"
}
variable "location" {
  type        = string
  default     = "europe-west8"
  description = "Location"
}

variable "storage_name" {
  type        = string
  default     = null
  description = "Name of the storage"
}

variable "sendgrid_api_key" {
  type        = string
  default     = null
  description = "send grid api key"
}

variable "mail_sender" {
  type        = string
  default     = null
  description = "mail sender"
}

variable "mail_receiver" {
  type        = string
  default     = null
  description = "mail receiver"
}

variable "storage_temp_name" {
  type        = string
  description = "Storage used for temp files (builds/staging etc)"
}