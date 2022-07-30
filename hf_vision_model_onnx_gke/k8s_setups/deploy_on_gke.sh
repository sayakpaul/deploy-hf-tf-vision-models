#! /bin/sh -i

# Set up env vars.
export GCP_PROJECT_ID=fast-ai-exploration
export IMAGE_NAME=fastapi-k8s
export VERSION=latest
export BASE_IMAGE_TAG=gcr.io/$GCP_PROJECT_ID/$IMAGE_NAME:$VERSION

export GKE_CLUSTER_NAME=fastapi-cluster
export GKE_CLUSTER_ZONE=us-central1-a
export GKE_DEPLOYMENT_NAME=fastapi-server

source ~/.bashrc
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Authenticate cluster.
gcloud container clusters get-credentials $GKE_CLUSTER_NAME --zone $GKE_CLUSTER_ZONE --project $GCP_PROJECT_ID  

cd ../.kube

# Deploy.
./kustomize build . | kubectl apply -f -
kubectl rollout status deployment/$GKE_DEPLOYMENT_NAME
kubectl get services -o wide
kubectl describe deployment $GKE_DEPLOYMENT_NAME
