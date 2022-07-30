#! /bin/sh -i

export ROOT_DIR=/tmp

export GCP_PROJECT_ID=fast-ai-exploration
export BASE_IMAGE_TAG=gcr.io/fast-ai-exploration/tfserving-n2

### Repository where to download SavedModel from
export MODEL_RELEASE_REPO=sayakpaul/deploy-hf-tf-vision-models
export MODEL_RELEASE_TAG=1.0
export MODEL_RELEASE_FILE=saved_model.tar.gz

### Model name to be embeded into the TFServing 
export MODEL_NAME=hf-vit
### VERSION which will be added at the end of Docker Image tag
export VERSION=latest

source ~/.bashrc

wget https://github.com/$MODEL_RELEASE_REPO/releases/download/$MODEL_RELEASE_TAG/$MODEL_RELEASE_FILE
mv saved_model.tar.gz $ROOT_DIR/$MODEL_RELEASE_FILE
mkdir -p $ROOT_DIR/$MODEL_NAME/1
tar -xvf $ROOT_DIR/$MODEL_RELEASE_FILE --strip-components=1 --directory $ROOT_DIR/$MODEL_NAME/1

docker kill serving_base
docker rm serving_base
docker run -d --name serving_base $BASE_IMAGE_TAG
docker cp $ROOT_DIR/$MODEL_NAME serving_base:/models/$MODEL_NAME

gcloud --quiet auth configure-docker
export NEW_IMAGE_NAME=tfserving-$MODEL_NAME:$VERSION
export NEW_IMAGE_TAG=gcr.io/$GCP_PROJECT_ID/$NEW_IMAGE_NAME
docker commit --change "ENV MODEL_NAME $MODEL_NAME" serving_base $NEW_IMAGE_TAG
docker push $NEW_IMAGE_TAG