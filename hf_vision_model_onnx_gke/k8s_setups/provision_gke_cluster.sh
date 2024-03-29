#! /bin/sh -i

# Set up env vars.
export GKE_CLUSTER_NAME=fastapi-cluster
export GKE_CLUSTER_ZONE=us-central1-a
export NUM_NODES=2

# export NUM_CORES=8
# export MEM_CAPACITY=16384
export MACHINE_TYPE=c2-standard-8

source ~/.bashrc
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Create k8s cluster on GKE.
gcloud container clusters create $GKE_CLUSTER_NAME \
    --zone=$GKE_CLUSTER_ZONE \
    --machine-type=$MACHINE_TYPE \
    --num-nodes=$NUM_NODES 
