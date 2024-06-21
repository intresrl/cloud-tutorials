output "bucket_public_url" {
  value = module.website.website_url
}

output "public_ip" {
  value = module.load_balancer.public_ip
}

output "final_url" {
  value = "https://${var.domain}/index.html"
}
