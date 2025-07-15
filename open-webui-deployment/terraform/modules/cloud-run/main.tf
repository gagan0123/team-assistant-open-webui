# Define the Cloud Run service
resource "google_cloud_run_v2_service" "default" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  template {
    service_account = var.service_account_email
    containers {
      image = var.image_uri

      # Allocate resources. This is a good starting point.
      resources {
        limits = {
          cpu    = "2"
          memory = "4Gi"
        }
      }

      # The port the application listens on inside the container
      ports {
        container_port = 8080
      }

      # This is the critical part: securely injecting the secret as an environment variable
      env {
        name = "WEBUI_SECRET_KEY"
        value_source {
          secret_key_ref {
            secret  = var.webui_secret_name
            version = "latest"
          }
        }
      }

      # This startup probe gives the app up to 4 minutes to start before Cloud Run gives up.
      # This is essential for Open WebUI as it loads models on boot.
      startup_probe {
        timeout_seconds   = 240
        period_seconds    = 240
        failure_threshold = 1
        tcp_socket {
          port = 8080
        }
      }
    }
  }
}

# Allow public, unauthenticated access to the service for our MVP
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "noauth" {
  project  = google_cloud_run_v2_service.default.project
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
