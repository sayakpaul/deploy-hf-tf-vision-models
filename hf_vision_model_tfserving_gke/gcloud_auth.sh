export GCP_PROJECT_ID=gcp-ml-172005
export SA_KEY_FILE=/tmp/gcp-ml-172005-5c6ccb3685b9.json

echo $SA_KEY_FILE

gcloud auth activate-service-account --key-file $SA_KEY_FILE
gcloud config set project $GCP_PROJECT_ID