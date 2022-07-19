# Deploy 🤗 `transformers` ViT model with TF Serving on GKE

There are six shell scripts to deploy 🤗 `transformers` ViT model with TF Serving on GKE. Some of them may be skipped depending on your local dev environment, but if you're starting from scratch, then run all the scripts sequentially.

1. `./install_gcloud.sh`
    - This downloads and installs `gcloud` tool, `docker-credential-gcr` and `gke-gcloud-auth-plugin` components from `gcloud` CLI. 
  
    - Skip this step if you already have `gcloud` installed on your system. 
      - When you skip, and if you have not installed `docker-credential-gcr` and `gke-gcloud-auth-plugin` components yet, you should install them manually using `gcloud`.

2. `./gcloud_auth.sh`
    - This authenticates the access from `gcloud` to `GCP` project. Here are variables that you might need to customize inside the script.
      - `GCP_PROJECT_ID`: GCP project ID to autheticate

    - Skip this step if you have already authenticated beforehand.

3. `./build_tfserving.sh`
    - This builds and pushes a custom TF Serving Docker image with 🤗 `transformers` ViT model. It basically follows the [official document](https://www.tensorflow.org/tfx/serving/docker) to build an image.
    - Here are variables that you might need to customize inside the script
        - `GCP_PROJECT_ID`: GCP project ID to push custom built TF Serving Docker image
        - `BASE_IMAGE_TAG`: Custom image will be built on top of this base TF Serving Docker image. This is set to `gcr.io/gcp-ml-172005/tfs-resnet-cpu-opt` by default which is CPU optimized TF Serving Docker image
        - `MODEL_RELEASE_REPO`: GitHub repository where to download the released model. This should follow the format of `username/reponame`. This is set to `sayakpaul/deploy-hf-tf-vision-models` by default
        - `MODEL_RELEASE_TAG`: Tag name of the GitHub Release where to download the released model. This is set to `1.0` by default
        - `MODEL_RELEASE_FILE`: Model filename to download from the GitHub Release's Asset under `MODEL_RELEASE_REPO` and `MODEL_RELEASE_TAG`. This is set to `saved_model.tar.gz` by default
        - `MODEL_NAME`: Model name to be exposed to client as an endpoint from TFServing. For instance, the endpoint follows the format of `http://IP_ADDRESS:PORT_NUMBER/v1/models/MODEL_NAME:predict`. This is set to `hf-vit` by default
        - `VERSION`: Version information for the custom built TF Serving Docker image. For instance, the tag of the custom built TF Serving Docker image follows the format of `tfserving-MODEL_NAME:VERSION`. This is set to `latest` by default, so the tag will be formed as `tfserving-hf-vit:latest` by default.

4. `./provision_gke_cluster.sh`
    - This provisions a GKE clusters with `gcloud container clusters` CLI. Here are variables that you might need to customize inside the script. Most of the values in this scripts are set with the optimal values according to [this experiments](https://github.com/deep-diver/ml-deployment-k8s-tfserving)
      - `GKE_CLUSTER_NAME`: GKE cluster name. This is set to `tfs-cluster` by default.
      - `GKE_CLUSTER_ZONE`: Zonal information where the GKE cluster is going to be provisioned. This is set to `us-central1-a` by default.
      - `NUM_NODES`: Number of nodes of the GKE cluster. This is set to `2` by default.
      - `NUM_CORES`: Number of CPU cores for each node(VM) of the GKE cluster. This is set to 8
      - `MEM_CAPACITY`: Memory capacity for each node(VM) of the GKE cluster in `MiB`. THis is set to `16384` by default which is 16GB RAM.

5. `./install_kustomize.sh`
    - This downloads and installs `Kustomize` tool under `.kube` directory.

6. `./deploy_tfserving_gke.sh`: 
    - This apply `Deployment` and `Service` to the GKE cluster using `Kustomize`. Essentially, the deployment will be applied using `kustomize build experiments/$TARGET_EXPERIMENT`. This means `Kustomize` constructs yamls by overlaying the base ones in `.kube/base` with specific ones in `.kube/experiments/$TARGET_EXPERIMENT`
    
    - There is a only experiment at the moment, but you can simply add more configurations under `.kube/experiments` by inherting base ones.
    
    - Here are variables that you might need to customize inside the script.
      - `GCP_PROJECT_ID`: GCP project ID where the GKE cluster is
      - `BASE_IMAGE_TAG`, `MODEL_NAME`, `VERSION`, `NEW_IMAGE_NAME`: Same values as in `./build_tfserving.sh` script
      - `GKE_CLUSTER_NAME`, `GKE_CLUSTER_ZONE`: Same values as in `./provision_gke_cluster.sh` script
      - `TARGET_EXPERIMENT`: Name of the overlay configurations under `.kube/experiments`. This is set to `8vCPU+16GB+inter_op4` by default.
      - `GKE_DEPLOYMENT_NAME`: Name of the `Deployment`. This is set to `tfs-server` by default. This is going to be used to check rollout status of the deployment. 