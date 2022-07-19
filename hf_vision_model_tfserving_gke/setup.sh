#! /bin/sh

GCP_PROJECT_ID=gcp-ml-172005
SA_KEY_FILE=/tmp/gcp-ml-172005-5c6ccb3685b9.json

GKE_CLUSTER_NAME=cluster-1
GKE_CLUSTER_ZONE=us-central1-a

# Download gcloud CLI tool
ROOT_DIR=/tmp
SAVED_FILENAME=gcloud_cli.tar.gz
GCLOUD_DIRNAME=google-cloud-sdk
curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-393.0.0-linux-x86_64.tar.gz > $ROOT_DIR/$SAVED_FILENAME
tar -xf $ROOT_DIR/$SAVED_FILENAME -C $ROOT_DIR

# Install gcloud CLI tool
CLOUDSDK_CORE_DISABLE_PROMPTS=1 $ROOT_DIR/$GCLOUD_DIRNAME/install.sh

# Auth gcloud with service account key file
GCLOUD_CMD=$ROOT_DIR/$GCLOUD_DIRNAME/bin/gcloud
$GCLOUD_CMD auth activate-service-account --key-file $SA_KEY_FILE
$GCLOUD_CMD config set project $GCP_PROJECT_ID

# Docker auth
$GCLOUD_CMD --quiet auth configure-docker

# GKE cluster auth
CLOUDSDK_CORE_DISABLE_PROMPTS=1 $GCLOUD_CMD components install gke-gcloud-auth-plugin
# if above doesn't work, try $ sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
$GCLOUD_CMD container clusters get-credentials $GKE_CLUSTER_NAME --zone $GKE_CLUSTER_ZONE --project $GCP_PROJECT_ID  