variable "rg_name" {
  type        = string
  default     = null
  description = "Resource group name"
}

variable "location" {
  type        = string
  default     = null
  description = "Location"
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

variable "landarea_storage_connstring" {
  type        = string
  default     = null
  description = "connection string for the land area"
}

variable "key_vault_id" {
  type        = string
  default     = null
  description = "key vault id"
}

variable "fn_service_plan" {
  type        = string
  default     = null
  description = "service plan for all functions"
}
variable "fn_storage_account_name" {
  type        = string
  default     = null
  description = "storage account name used for all functions"
}
variable "fn_storage_account_access_key" {
  type        = string
  default     = null
  description = "storage account key used for all functions"
}
