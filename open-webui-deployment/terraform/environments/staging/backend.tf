terraform {
  backend "gcs" {
    bucket = "ta-opwui-v3-tf-state-staging"
    prefix = "terraform/state"
  }
}
