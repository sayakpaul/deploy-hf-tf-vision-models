#! /bin/sh -i

export ROOT_DIR=/tmp
export SAVED_FILENAME=gcloud_cli.tar.gz
export GCLOUD_DIRNAME=google-cloud-sdk
export GCLOUD_CMD=$ROOT_DIR/$GCLOUD_DIRNAME/bin
echo "export PATH=$PATH:${GCLOUD_CMD}" >> ~/.bashrc 

curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-393.0.0-linux-x86_64.tar.gz > $ROOT_DIR/$SAVED_FILENAME
tar -xf $ROOT_DIR/$SAVED_FILENAME -C $ROOT_DIR

source ~/.bashrc
CLOUDSDK_CORE_DISABLE_PROMPTS=1 $ROOT_DIR/$GCLOUD_DIRNAME/install.sh
CLOUDSDK_CORE_DISABLE_PROMPTS=1 gcloud components install docker-credential-gcr
CLOUDSDK_CORE_DISABLE_PROMPTS=1 gcloud components install gke-gcloud-auth-plugin