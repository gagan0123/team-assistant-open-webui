#!/bin/bash

# Extract project_id from terraform.tfvars
PROJECT_ID=$(grep -o 'project_id = "[^"]*"' terraform.tfvars | cut -d'"' -f2)

if [ -z "$PROJECT_ID" ]; then
  echo "Error: Could not extract project_id from terraform.tfvars"
  echo "Please make sure project_id is defined in terraform.tfvars"
  exit 1
fi

# Construct bucket name using project_id
BUCKET_NAME="${PROJECT_ID}-terraform-state"

# Get the bucket name from backend.tf for verification
BACKEND_BUCKET=$(grep -o 'bucket = "[^"]*"' backend.tf | cut -d'"' -f2)

# Verify that the bucket name in backend.tf matches the expected format
if [ "$BACKEND_BUCKET" != "$BUCKET_NAME" ]; then
  echo "Warning: The bucket name in backend.tf ($BACKEND_BUCKET) does not match the expected name based on project_id ($BUCKET_NAME)"
  echo "Consider updating backend.tf to use $BUCKET_NAME"

  # Ask for confirmation to proceed
  read -p "Do you want to proceed with creating bucket $BACKEND_BUCKET instead? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled. Please update backend.tf or terraform.tfvars to ensure consistency."
    exit 1
  fi

  # Use the bucket name from backend.tf if confirmed
  BUCKET_NAME=$BACKEND_BUCKET
fi

# Check if the bucket exists
if gsutil ls -b gs://$BUCKET_NAME > /dev/null 2>&1; then
  echo "Bucket gs://$BUCKET_NAME already exists."
else
  echo "Bucket gs://$BUCKET_NAME does not exist. Creating..."
  gsutil mb gs://$BUCKET_NAME

  # Enable versioning on the bucket
  echo "Enabling versioning on gs://$BUCKET_NAME..."
  gsutil versioning set on gs://$BUCKET_NAME

  echo "Bucket gs://$BUCKET_NAME created and versioning enabled."
fi

echo "You can now run 'terraform init' to initialize Terraform."
