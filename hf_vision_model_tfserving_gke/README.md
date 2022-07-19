# Deploy 🤗 `transformers` ViT model with TFServing on GKE

There are five shell scripts to deploy 🤗 `transformers` ViT model with TF Serving on GKE. Some of them may be skipped depending on your local dev environment, but if you're starting from scratch, then run all the scripts sequentially.

1. `bash ./install_gcloud.sh`: Installs `gcloud` CLI tool, `docker-credential-gcr` and `gke-gcloud-auth-plugin` components from `gcloud` CLI. 
    - Skip if you already have `gcloud`. 
    - When you skip, and if you have not installed `docker-credential-gcr` and `gke-gcloud-auth-plugin` components yet, you should install them manually using `gcloud`.

2. `bash ./gcloud_auth.sh`: Authenticate the access from `gcloud` to your `GCP`
    - Skip if you have already authenticated `gcloud`.
    - If you have not authenticated `gcloud`, you should download Service Account key (JSON) and provide the path in `SA_KEY_FILE` variable. Also speicy your GCP project ID in `GCP_PROJECT_ID` variable.

3. `bash ./build_tfserving.sh`: Builds and pushes a custom TFServing Docker image with 🤗 `transformers` ViT model. 
    - `GCP_PROJECT_ID`: GCP project ID where you want to push a custom built TFServing Docker image
    - `BASE_IMAGE_TAG`: Base TFServing Docker image. Your custom image will be built on top of this.
    - `MODEL_RELEASE_REPO`: GitHub repository (`username/reponame`)
    - `MODEL_RELEASE_TAG`: GitHub Release tag 
    - `MODEL_RELEASE_FILE`: Asset filename to download from GitHub Release under `MODEL_RELEASE_REPO` and `MODEL_RELEASE_TAG`
    - `MODEL_NAME`: Model name to be exposed to client as an endpoint from TFServing
    - `VERSION`: Version information for the custom built TFServing Docker image

4. `bash ./install_kustomize.sh`: installs `Kustomize` CLI tool under `.kube` directory.

5. `bash ./provision_gke.sh`: provision `Deployment` and `Service` to the GKE cluster.
    - Set `MODEL_NAME`, `VERSION` to same as in `./build_tfserving.sh`
    - Set `GKE_CLUSTER_NAME` and `GKE_CLUSTER_ZONE` to specify the GKE cluster that you have already provisioned