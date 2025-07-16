# 1. Health Check: To see if the application is alive
resource "google_compute_health_check" "default" {
  project = var.project_id
  name    = "${var.lb_name}-health-check"
  http_health_check {
    port = "8080"
    request_path = "/"
  }
}

# 2. Backend Service: Defines how the LB connects to the VMs
resource "google_compute_backend_service" "default" {
  project     = var.project_id
  name        = "${var.lb_name}-backend-service"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30
  health_checks = [google_compute_health_check.default.id]
  
  backend {
    group = var.instance_group_link
  }

  # This is the magic: Enable IAP on this backend
  iap {
    oauth2_client_id     = google_iap_client.default.client_id
    oauth2_client_secret = google_iap_client.default.secret
  }
}

# 3. URL Map: Directs all incoming traffic to our one backend
resource "google_compute_url_map" "default" {
  project         = var.project_id
  name            = "${var.lb_name}-url-map"
  default_service = google_compute_backend_service.default.id
}

# 4. SSL Certificate: Google-managed cert for our domain
resource "google_compute_managed_ssl_certificate" "default" {
  project = var.project_id
  name    = "${var.lb_name}-ssl-cert"
  managed {
    domains = [var.domain_name]
  }
}

# 5. Target Proxy: Binds the SSL cert to the URL map
resource "google_compute_target_https_proxy" "default" {
  project          = var.project_id
  name             = "${var.lb_name}-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

# 6. Public IP Address: A global static IP for the LB
resource "google_compute_global_address" "default" {
  project = var.project_id
  name    = "${var.lb_name}-ip"
}

# 7. Forwarding Rule: The final piece that connects the public IP to the proxy (the LB's frontend)
resource "google_compute_global_forwarding_rule" "default" {
  project      = var.project_id
  name         = "${var.lb_name}-forwarding-rule"
  target       = google_compute_target_https_proxy.default.id
  ip_address   = google_compute_global_address.default.address
  port_range   = "443"
  ip_protocol  = "TCP"
}

# --- IAP Configuration Resources ---

# 8. IAP Brand: A one-time setup for the project to create the consent screen
resource "google_iap_brand" "project_brand" {
  project          = var.project_id
  support_email    = var.support_email
  application_title = "Open WebUI"
}

# 9. IAP Client: The OAuth client associated with the brand
resource "google_iap_client" "default" {
  display_name = "Open WebUI IAP Client"
  brand        = google_iap_brand.project_brand.name
}

# 10. IAP Permissions: Grant access to the specified members
resource "google_iap_web_backend_service_iam_member" "default" {
  for_each           = toset(var.iap_members)
  project            = var.project_id
  web_backend_service = google_compute_backend_service.default.name
  role               = "roles/iap.httpsResourceAccessor"
  member             = each.key
}



