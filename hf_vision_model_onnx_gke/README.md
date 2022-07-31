# Deploying an ONNX-optimized version of TF ViT from 🤗 Transformers with Docker and Kubernetes

This directory contains the files necessary to deploy an ONNX-optimized version
of the [TF ViT model from 🤗 Transformers](https://huggingface.co/docs/transformers/main/en/model_doc/vit#transformers.TFViTModel) with Docker and Kubernetes. We use [Kubernetes Engine](https://cloud.google.com/kubernetes-engine) for managing the Kubernetes cluster. More specifically, the ONNX model is deployed as a REST endpoint through [FastAPI](https://fastapi.tiangolo.com/).

Below, you'll find all the step-by-step instructions for performing the deployment. If you'd
like to locally deploy the FastAPI first refer [to this section](#local-deployment).

## Obtain the ONNX model

Consult the `misc/convert-to-onnx.ipynb` notebook for this. Note that it's often helpful
to generate the ONNX model on the hardware that will be used for deploying the model.

In this case, we used a [`c2` type machine on GCP](https://cloud.google.com/compute/docs/compute-optimized-machines#c2_machine_types) to take advantage of its support for
advanced instructions sets like [AVX-512](https://en.wikipedia.org/wiki/AVX-512) suited for deep learning inference. 

You can download the ONNX file from [here](https://github.com/sayakpaul/deploy-hf-tf-vision-models/releases/download/2.0/vit-base-patch16-224.onnx).

Once the ONNX model is obtained you can proceed to the rest of the steps. 

## Install dependencies and setups required for `gcloud`

Consult `../hf_vision_model_tfserving_gke/install_gcloud.sh` and the README of `../hf_vision_model_tfserving_gke`. 

## Building the Docker image

Consult `build_docker_image.sh` that builds a containerizes our FastAPI app and pushes it [Google Container
Registry](https://cloud.google.com/container-registry). Once the Docker image is pushed
we can deploy it on a Kubernetes cluster through Kubernetes Engine.

## Deployment on Kubernetes Engine

For this you'll need to change the current working directory to `k8s_setups`. All the steps below 
need to be executed in order.

1. Install `kustomize` that is used for orchestrating the deployment. Consult 
the `k8s_setups/install_kustomize.sh` script.

2. Provision the Kubernetes cluster on Kubernetes Engine. Consult the `k8s_setups/provision_gke_cluster.sh` script.

3. Our deployment specifications for Kubernetes are present in the `../.kube` directory. To roll out
the deployment, run the `k8s_setups/deploy_on_gke.sh` script. After the deployment has been rolled out
successfully we need to get the external IP of the service called `fastapi-server`. 

    Run `kubectl get services` and look for `fastapi-server`. Note down the external IP associated to it. If it's still
    in the "PENDING" state, wait for some time and then run the `kubectl get services` command again.

    You should get something like this:

    ```bash
    NAME             TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE
    fastapi-server   LoadBalancer   10.120.8.29   1.2.3.4   80:32743/TCP   44s
    kubernetes       ClusterIP      10.120.0.1    <none>          443/TCP        26m
    ```

    **Note** that the external IP might be different in your case.

Now, we can query the endpoint like so:

```shell
curl -X POST -F image_file=@../misc/image.jpg -F with_resize=True -F with_post_process=True http://<EXTERNAL-IP>:80/predict/image
```

You should get the following output:

```shell
"{\"Label\": \"Egyptian cat\", \"Score\": \"12.377\"}"
```

## Local deployment

Consult [this link](https://github.com/sayakpaul/ml-deployment-k8s-fastapi/tree/main/api).

## Notes

[This repository](https://github.com/sayakpaul/ml-deployment-k8s-fastapi) shows an automated way to perform these kinds of deployments incorporating good CI/CD practices. 