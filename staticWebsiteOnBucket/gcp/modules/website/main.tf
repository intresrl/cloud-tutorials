
# Random used to generate a unique name for the resources
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

# Create the storage bucket where books will be stored
resource "google_storage_bucket" "website" {
  name          = "${var.bucket_name}-${random_id.bucket_prefix.hex}"
  location      = var.location
  force_destroy = true

  website {
    main_page_suffix = "index.html"
  }
  uniform_bucket_level_access = true

}

# Make the bucket public
resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Load files on bucket
locals {
  src_path = "website-src"
}
resource "google_storage_bucket_object" "default" {
  for_each = fileset(path.module, "${local.src_path}/**")
  name     = replace(each.value, "/^${local.src_path}\\//", "")
  source   = "modules/website/${each.value}"
  bucket   = google_storage_bucket.website.id
}