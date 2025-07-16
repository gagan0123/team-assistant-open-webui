terraform {
  backend "gcs" {
    bucket = "ta-opwui-v4-tf-state-staging"
    prefix = "terraform/state"
  }
}

