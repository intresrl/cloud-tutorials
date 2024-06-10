output "bucket_console_url" {
  value = "https://console.cloud.google.com/storage/browser/${google_storage_bucket.land_area.name}"
}

output "appengine_public_url" {
  value = module.app-engine.appengine_url
}