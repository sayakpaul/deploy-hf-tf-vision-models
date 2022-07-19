#! /bin/sh
# This shell script apply Deployment to the designated GKE cluster
# Prerequisite: You should provision GKE cluster beforehand

## 0. Define Variables
GCP_PROJECT_ID=gcp-ml-172005
### Path where service account key file is (JSON)
SA_KEY_FILE=/tmp/gcp-ml-172005-5c6ccb3685b9.json

GKE_CLUSTER_NAME=cluster-1
GKE_CLUSTER_ZONE=us-central1-c

### Base TFServing Docker image
BASE_IMAGE_TAG=gcr.io/gcp-ml-172005/tfs-resnet-cpu-opt

### Repository where to download SavedModel from
MODEL_RELEASE_REPO=deep-diver/deploy-hf-tf-vision-models
MODEL_RELEASE_TAG=1.0
MODEL_RELEASE_FILE=saved_model.tar.gz

### Model name to be embeded into the TFServing 
MODEL_NAME=hf-vit
### VERSION which will be added at the end of Docker Image tag
VERSION=latest

GKE_DEPLOYMENT_NAME=tfs-server
TARGET_EXPERIMENT="8vCPU+16GB+inter_op4"

### -z is a testing functionality
if [ -z ${GCP_PROJECT_ID} ] || \
   [ -z ${SA_KEY_FILE} ] || \
   [ -z ${GKE_CLUSTER_NAME} ] || \
   [ -z ${GKE_CLUSTER_ZONE} ] ||  \
   [ -z ${BASE_IMAGE_TAG} ] || \
   [ -z ${MODEL_RELEASE_FILE} ] || \
   [ -z ${MODEL_NAME} ] || \
   [ -z ${VERSION} ] || \
   [ -z ${GKE_DEPLOYMENT_NAME} ] || \
   [ -z ${TARGET_EXPERIMENT} ]
then
    echo "Some variables in the shell script are not set. Check them with the below outputs"
    echo "GCP_PROJECT_ID=$GCP_PROJECT_ID"
    echo "SA_KEY_FILE=$SA_KEY_FILE"
    echo "GKE_CLUSTER_NAME=$GKE_CLUSTER_NAME"
    echo "GKE_CLUSTER_ZONE=$GKE_CLUSTER_ZONE"
    echo "BASE_IMAGE_TAG=$BASE_IMAGE_TAG"
    echo "MODEL_RELEASE_FILE=$MODEL_RELEASE_FILE"
    echo "MODEL_NAME=$MODEL_NAME"
    echo "VERSION=$VERSION"
    echo "GKE_DEPLOYMENT_NAME=$GKE_DEPLOYMENT_NAME"
    echo "TARGET_EXPERIMENT=$TARGET_EXPERIMENT"
    exit 
fi

## 1. Download gcloud CLI tool
ROOT_DIR=/tmp
SAVED_FILENAME=gcloud_cli.tar.gz
GCLOUD_DIRNAME=google-cloud-sdk
curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-393.0.0-linux-x86_64.tar.gz > $ROOT_DIR/$SAVED_FILENAME
tar -xf $ROOT_DIR/$SAVED_FILENAME -C $ROOT_DIR

## 2. Install gcloud CLI tool
CLOUDSDK_CORE_DISABLE_PROMPTS=1 $ROOT_DIR/$GCLOUD_DIRNAME/install.sh

## 3. Auth gcloud with service account key file
GCLOUD_CMD=$ROOT_DIR/$GCLOUD_DIRNAME/bin/gcloud
$GCLOUD_CMD auth activate-service-account --key-file $SA_KEY_FILE
$GCLOUD_CMD config set project $GCP_PROJECT_ID

## 4. Docker auth
CLOUDSDK_CORE_DISABLE_PROMPTS=1 $GCLOUD_CMD components install docker-credential-gcr
export PATH=$PATH:$ROOT_DIR/$GCLOUD_DIRNAME/bin
$GCLOUD_CMD --quiet auth configure-docker

## 5. GKE cluster auth
CLOUDSDK_CORE_DISABLE_PROMPTS=1 $GCLOUD_CMD components install gke-gcloud-auth-plugin
# if above doesn't work, try $ sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
$GCLOUD_CMD container clusters get-credentials $GKE_CLUSTER_NAME --zone $GKE_CLUSTER_ZONE --project $GCP_PROJECT_ID  


## 6. Download SavedModel  
wget https://github.com/$MODEL_RELEASE_REPO/releases/download/$MODEL_RELEASE_TAG/$MODEL_RELEASE_FILE
mv saved_model.tar.gz $ROOT_DIR/$MODEL_RELEASE_FILE

## 7. Untar the SavedModel
mkdir -p $ROOT_DIR/$MODEL_NAME/1
tar -xvf $ROOT_DIR/$MODEL_RELEASE_FILE --strip-components=1 --directory $ROOT_DIR/$MODEL_NAME/1

## 8. Copy the SavedModel into a running base TFServing Docker continaer
docker kill serving_base
docker rm serving_base
docker run -d --name serving_base $BASE_IMAGE_TAG
docker cp $ROOT_DIR/$MODEL_NAME serving_base:/models/$MODEL_NAME

## 9. Commit changes and push the custom TFServing Docker image
export NEW_IMAGE_NAME=tfserving-$MODEL_NAME:$VERSION
export NEW_IMAGE_TAG=gcr.io/$GCP_PROJECT_ID/$NEW_IMAGE_NAME
docker commit --change "ENV MODEL_NAME $MODEL_NAME" serving_base $NEW_IMAGE_TAG
docker push $NEW_IMAGE_TAG

## 10. Download Kustomize
cd .kube
curl -sfLo kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.1.2/kustomize_v4.1.2_linux_amd64.tar.gz
tar -zxvf kustomize.tar.gz
rm kustomize.tar.gz
chmod u+x ./kustomize
export PATH=$PATH:$(pwd)

## 11. Replace default image tag to newly built custom TFServing Docker image
cd experiments/$TARGET_EXPERIMENT
kustomize edit set image $BASE_IMAGE_TAG=$NEW_IMAGE_TAG

## 12. Provision Deployment, Service to GKE Cluster
cd ../..
kustomize build experiments/$TARGET_EXPERIMENT | kubectl apply -f -
kubectl rollout status deployment/$GKE_DEPLOYMENT_NAME
kubectl get services -o wide
kubectl describe deployment $GKE_DEPLOYMENT_NAME
