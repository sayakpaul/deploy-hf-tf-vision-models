#! /bin/sh -i

# Set up env vars.
export GCP_PROJECT_ID=fast-ai-exploration
export IMAGE_NAME=fastapi-k8s
export IMAGE="gcr.io/$GCP_PROJECT_ID/$IMAGE_NAME"

source ~/.bashrc
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Authenticate GCP to use Docker.
gcloud --quiet auth configure-docker

# Build image and push.
docker build --tag "$IMAGE:latest" .
docker push "$IMAGE:latest"