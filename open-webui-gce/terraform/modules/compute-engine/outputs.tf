output "instance_ip" {
  description = "The external IP address of the GCE instance."
  value       = google_compute_address.static.address
}

