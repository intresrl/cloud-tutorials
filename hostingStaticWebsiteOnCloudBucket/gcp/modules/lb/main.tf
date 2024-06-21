# Source:
# - https://cloud.google.com/load-balancing/docs/https/ext-load-balancer-backend-buckets#terraform
# - https://cloud.google.com/load-balancing/docs/ssl-certificates/google-managed-certs
# - https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map

# Create LB backend buckets
resource "google_compute_backend_bucket" "be_bucket_website" {
  name        = "be-${var.bucket_name}"
  description = "Contains website static content"
  bucket_name = var.bucket_name
}

# Create url map
resource "google_compute_url_map" "default" {
  name = "${var.bucket_name}-https-lb"

  default_service = google_compute_backend_bucket.be_bucket_website.id

  #   host_rule {
  #     #hosts        = [var.domain]
  #     hosts        = ["*"]
  #     path_matcher = "allpaths"
  #   }

  #   host_rule {
  #     hosts        = ["*"]
  #     path_matcher = "path-matcher-2"
  #   }
  #   path_matcher {
  #     name            = "path-matcher-2"
  #     default_service = var.bucket_id
  #
  #     path_rule {
  #       paths   = ["/love-to-fetch/*"]
  #       service = var.bucket_id
  #     }
  #   }
}

# SSL certificate
resource "google_compute_managed_ssl_certificate" "lb_default" {
  provider = google-beta
  name     = "${var.bucket_name}-ssl-cert"
  project  = var.project
  managed {
    domains = [var.domain]
  }
}

# Https proxy
resource "google_compute_target_https_proxy" "default" {
  name             = "test-proxy"
  project          = var.project
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.lb_default.id]
}

# Reserve IP address
resource "google_compute_global_address" "ip" {
  name = "${var.bucket_name}-public-ip"
}

# Create forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "${var.bucket_name}-https-lb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.default.id
  ip_address            = google_compute_global_address.ip.id
}

