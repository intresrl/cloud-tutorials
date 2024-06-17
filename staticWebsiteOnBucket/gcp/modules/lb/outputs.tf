output "public_ip" {
  value = google_compute_global_address.ip.address
}
