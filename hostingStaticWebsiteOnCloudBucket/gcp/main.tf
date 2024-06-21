######
# Enable required api
variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type = list(string)
  default = [
    "compute.googleapis.com"
  ]
}
resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project = var.project_id
  service = each.key
}

module "website" {
  source = "./modules/website"

  project     = var.project_id
  location    = var.location
  bucket_name = var.bucket_name

  depends_on = [google_project_service.gcp_services]

  providers = {
    google = google.provider
  }

}

module "load_balancer" {
  source = "./modules/lb"

  project     = var.project_id
  location    = var.location
  bucket_name = module.website.bucket_name
  domain      = var.domain

  depends_on = [google_project_service.gcp_services]

  providers = {
    google = google.provider
  }

}