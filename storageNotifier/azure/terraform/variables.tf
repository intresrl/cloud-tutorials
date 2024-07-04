variable "rg_name" {
  type        = string
  #If you prefer to use another resource group name, you can change it here
  default     = "myrg"
  description = "Resource group prefix name"
}

variable "location" {
  type        = string
  #If you prefer to use another location, you can change it here
  default     = "westeurope"
  description = "Location"
}

variable "sendgrid_api_key" {
  type        = string
  #Insert sendgrid api key
  default     = ""
  description = "send grid api key"
}

variable "mail_sender" {
  type        = string
  #Insert email address from where you want to send the notification
  default     = ""
  description = "mail sender"
}

variable "mail_receiver" {
  type        = string
  #Insert email address where you want to receive the notification
  default     = ""
  description = "mail receiver"
}