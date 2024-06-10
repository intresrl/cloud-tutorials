variable "storage_temp_name" {
  type        = string
  description = "Storage used for temp files (builds/staging etc)"
}

variable "template_name" {
  type        = string
  default     = "bookToPhrase-batch.json"
  description = "Name of the dataflow template"
}

variable "template_folder" {
  type        = string
  default     = "dataflow-templates"
  description = "Folder where the dataflow template will be stored"
}

variable "dataflow_batch_image" {
  type        = string
  description = "Dataflow flex template docker image"
}