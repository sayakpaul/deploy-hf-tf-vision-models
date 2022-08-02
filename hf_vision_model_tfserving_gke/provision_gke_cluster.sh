#! /bin/sh -i

export GKE_CLUSTER_NAME=tfs-cluster
export GKE_CLUSTER_ZONE=us-central1-a
export NUM_NODES=2

# export NUM_CORES=8
# export MEM_CAPACITY=16384
export MACHINE_TYPE=n1-standard-8

source ~/.bashrc
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

gcloud container clusters create $GKE_CLUSTER_NAME \
    --zone=$GKE_CLUSTER_ZONE \
    --machine-type=$MACHINE_TYPE \
    --num-nodes=$NUM_NODES 
