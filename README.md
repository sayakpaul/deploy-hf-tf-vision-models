# Deploying Vision Models (TensorFlow) from 🤗 Transformers

_By [Chansung Park](https://github.com/deep-diver) and [Sayak Paul](https://github.com/sayakpaul)_

This repository shows various ways of deploying a vision model (TensorFlow) from 🤗 Transformers using the TensorFlow Ecosystem. In particular, we use TensorFlow Serving (for local deployment), Vertex AI (serveless deployment), Kubernetes and GKE (more controlled deployment) with TensorFlow Serving and ONNX.

For this project, we leverage Google Cloud Platform for using managed services [Vertex AI](https://cloud.google.com/vertex-ai) and [GKE](https://cloud.google.com/kubernetes-engine). 

## Methods covered

- [x] [Local TensorFlow Serving](https://github.com/sayakpaul/deploy-hf-tf-vision-models/blob/main/hf_vision_model_tfserving.ipynb) | [Blog post from 🤗](https://huggingface.co/blog/tf-serving-vision)
  - We cover how to locally deploy a Vision Transformer (ViT) model from 🤗 Transformers with TensorFlow Serving. 
  - With this, you will be able to serve your own machine learning models in a standalone Python application.

- [x] [TensorFlow Serving on Kubernetes (GKE)](https://github.com/sayakpaul/deploy-hf-tf-vision-models/tree/main/hf_vision_model_tfserving_gke) | [Blog post from 🤗](https://huggingface.co/blog/deploy-tfserving-kubernetes)
  - We cover how to build a custom TensorFlow Serving Docker image with Vision Transformer (ViT) model from 🤗 Transformers, provision [Google Kubernetes Engine(GKE)]((https://cloud.google.com/kubernetes-engine)) cluster, deploy the Docker image to the GKE cluster.
  - Particularly, we cover Kubernetes specific topics such as creating Deployment/Service/HPA Kubernetes objects for scalable deployment of the Docker image to the nodes(VMs) and expose them as a service to clients.
  - With this, you will be able to serve and scale your own machine learning models according to the CPU utilizations of the deployment as a whole.
  - We provide utilities to perform load-test with [Locust](https://locust.io/) and visualization notebook as well. Refer [here](./hf_vision_model_tfserving_gke/locust) for more details.

- [x] [ONNX on Kubernetes (GKE)](https://github.com/sayakpaul/deploy-hf-tf-vision-models/tree/main/hf_vision_model_onnx_gke)
  - The workflow here is similar to the above one but here we used an ONNX-optimized version of the ViT model. 
  - ONNX is particularly useful when you're deploying models using x86 CPUs. 
  - This workflow doesn't require you to build any custom TF Serving image. 
  - One important thing to keep in mind is to generate the ONNX model in a machine type which is the same as the deployment hardware. This means if you're going to use the `n1-standard-8` machine type for deployment, generate the ONNX model in the same machine type to ensure ONNX optimizations are relevant. 

- [x] [Vertex AI Prediction](https://github.com/sayakpaul/deploy-hf-tf-vision-models/tree/main/hf_vision_model_vertex_ai) | [Blog post from 🤗](https://huggingface.co/blog/deploy-vertex-ai)
  - We cover how to deploy Vision Transformer (ViT) model from 🤗 Transformers to Google Cloud's fully managed machine learning deployment service ([Vertex AI Prediction]((https://cloud.google.com/vertex-ai/docs/predictions/getting-predictions))). 
  - Under the hood, Vertex AI Prediction leverages all the technologies from GKE, TensorFlow Serving, and more. 
  - That means you can deploy and scale the deployment of machine learning models, but you don't need to worry about building a custom Docker image or writing Kubernetes-specific manifests, or setting up model monitoring capability.
  - With this, you will be able to serve and scale your own machine learning model by calling various APIs from `google-cloud-aiplatform` SDK to interact with Vertex AI. 
  - We provide utilities to perform load-test with [Locust](https://locust.io/). Refer [here](./hf_vision_model_vertex_ai/locust) for more details.

- [ ] Vertex AI Prediction (w/ [optimized TFRT](https://cloud.google.com/vertex-ai/docs/predictions/optimized-tensorflow-runtime))
  - TBD
  - Know more about the optimized TFRT(TensorFlow RunTime) [here](https://github.com/tensorflow/runtime).

## Acknowledgements

We're thankful to the ML Developer Programs team at Google that provided GCP support. 
