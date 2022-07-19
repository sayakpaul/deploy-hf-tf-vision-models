export GCP_PROJECT_ID=gcp-ml-172005

eval "$(cat ~/.bashrc)"
gcloud auth login
gcloud config set project $GCP_PROJECT_ID