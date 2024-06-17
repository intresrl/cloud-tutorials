variable "project" {
  type        = string
  description = "Project id"
}

variable "location" {
  type        = string
  default     = "europe-west8"
  description = "Location"
}

variable "bucket_name" {
  type        = string
  description = "website bucket name"
}

variable "domain" {
  type        = string
  description = "domain name"
}