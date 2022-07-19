#! /bin/sh

export MODEL_NAME=hf-vit
export VERSION=latest
export NEW_IMAGE_NAME=tfserving-$MODEL_NAME:$VERSION
export NEW_IMAGE_TAG=gcr.io/$GCP_PROJECT_ID/$NEW_IMAGE_NAME
export BASE_IMAGE_TAG=gcr.io/gcp-ml-172005/tfs-resnet-cpu-opt

export GCP_PROJECT_ID=gcp-ml-172005

export GKE_CLUSTER_NAME=tfs-cluster
export GKE_CLUSTER_ZONE=us-central1-a
export GKE_DEPLOYMENT_NAME=tfs-server
export TARGET_EXPERIMENT="8vCPU+16GB+inter_op4"

eval "$(cat ~/.bashrc)"

export USE_GKE_GCLOUD_AUTH_PLUGIN=True
gcloud container clusters get-credentials $GKE_CLUSTER_NAME --zone $GKE_CLUSTER_ZONE --project $GCP_PROJECT_ID  

cd .kube
export PATH=$PATH:$(pwd)

cd experiments/$TARGET_EXPERIMENT
kustomize edit set image $BASE_IMAGE_TAG=$NEW_IMAGE_TAG

cd ../..
kustomize build experiments/$TARGET_EXPERIMENT | kubectl apply -f -
kubectl rollout status deployment/$GKE_DEPLOYMENT_NAME
kubectl get services -o wide
kubectl describe deployment $GKE_DEPLOYMENT_NAME
