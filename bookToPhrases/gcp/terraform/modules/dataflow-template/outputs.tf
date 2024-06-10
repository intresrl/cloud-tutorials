output "dataflow_template_path" {
  value = "gs://${var.storage_temp_name}/${google_storage_bucket_object.flex_template.output_name}"
}

output "file" {
  value = google_storage_bucket_object.flex_template
}