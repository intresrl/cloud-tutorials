variable "project_id" {
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
  default     = "static-website-bucket"
  description = "Location"
}

