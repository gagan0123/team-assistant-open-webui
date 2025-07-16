#!/bin/bash
# Log everything to a file
exec > >(tee /var/log/startup-script.log|logger -t startup-script -s 2>/dev/console) 2>&1

echo "--- Starting VM startup script ---"

# Update packages and install dependencies
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Install Docker
curl -fsSL get.docker.com | sh

# Create the application directory
mkdir -p /opt/open-webui
cd /opt/open-webui

# Authenticate Docker to Artifact Registry
echo "--- Authenticating to Artifact Registry in ${REGION} ---"
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

# Create the docker-compose file from metadata
echo "--- Creating docker-compose.yml ---"
cat <<EOF > docker-compose.yml
${DOCKER_COMPOSE_YML}
EOF

# Pull the images
echo "--- Pulling Docker images ---"
docker compose pull

# Start the services
echo "--- Starting services with docker compose ---"
docker compose up -d

echo "--- VM startup script finished ---"
