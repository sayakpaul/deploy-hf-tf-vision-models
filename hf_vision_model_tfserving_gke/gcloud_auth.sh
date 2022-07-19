#! /bin/sh -i

export GCP_PROJECT_ID=gcp-ml-172005

source ~/.bashrc
# export SA_KEY_FILE=/tmp/gcp-ml-172005-5c6ccb3685b9.json
# gcloud auth activate-service-account --key-file $SA_KEY_FILE
gcloud auth login
gcloud config set project $GCP_PROJECT_ID