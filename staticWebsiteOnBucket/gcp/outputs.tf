output "bucket_console_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.website.name}/index.html"
}
