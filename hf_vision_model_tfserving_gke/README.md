# Deploy 🤗 `transformers` ViT model with TF Serving on GKE

## Instructions to provision

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

After all of these steps goes successfully, you will see the output similar to below. There are two parts. 
- The first part shows the endpoints of the deployment. Port number `8500` is for `HTTP/1.1` based RESTful API, while port number `8501` is for `HTTP/2` based gRPC API. 

- The second part shows the rolling status of the deployment. Pay attention that `Image` is set correctly, and there are two `Ports` for `HTTP/1.1` and `HTTP/2`. Also, some TF Serving specific flags are set in the `Args` (i.e `tensorflow_inter_op_parallelism` and `tensorflow_intra_op_parallelism`). Finally `Replicas` shows there are desired number of pods running. 

```
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                         AGE     SELECTOR
kubernetes   ClusterIP      10.44.0.1      <none>          443/TCP                         6m51s   <none>
tfs-server   LoadBalancer   10.44.10.106   34.134.46.135   8500:32325/TCP,8501:30635/TCP   4m29s   app=tfs-server

Name:                   tfs-server
Namespace:              default
CreationTimestamp:      Tue, 19 Jul 2022 14:25:33 +0000
Labels:                 app=tfs-server
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               app=tfs-server
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=tfs-server
  Containers:
   tfs-k8s:
    Image:       gcr.io/gcp-ml-172005/tfserving-hf-vit:latest
    Ports:       8500/TCP, 8501/TCP
    Host Ports:  0/TCP, 0/TCP
    Args:
      --tensorflow_inter_op_parallelism=4
      --tensorflow_intra_op_parallelism=8
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   tfs-server-6fc97c4f68 (2/2 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  4m30s  deployment-controller  Scaled up replica set tfs-server-fcc588d44 to 2
  Normal  ScalingReplicaSet  27s    deployment-controller  Scaled up replica set tfs-server-6fc97c4f68 to 1
  Normal  ScalingReplicaSet  16s    deployment-controller  Scaled down replica set tfs-server-fcc588d44 to 1
  Normal  ScalingReplicaSet  15s    deployment-controller  Scaled up replica set tfs-server-6fc97c4f68 to 2
  Normal  ScalingReplicaSet  3s     deployment-controller  Scaled down replica set tfs-server-fcc588d44 to 0

```

## Instructions to perform inference with the endpoint

TBD