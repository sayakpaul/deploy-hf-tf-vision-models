# Deploying Vision Models (TensorFlow) from 🤗 Transformers

_By [Chansung Park](https://github.com/deep-diver) and [Sayak Paul](https://github.com/sayakpaul)_

This repository shows various ways of deploying a vision model (TensorFlow) from 🤗 Transformers using the TensorFlow Ecosystem. In particular, we use TensorFlow Serving (for local deployment), Vertex AI (serveless deployment), Kubernetes and GKE (more controlled deployment).

## Methods covered

- [x] Local TensorFlow Serving | [Blog post from 🤗](https://huggingface.co/blog/tf-serving-vision)
  - We cover how to locally deploy a Vision Transformer (ViT) model from 🤗 Transformers with TensorFlow Serving. 
  - With this, you will be able to serve your own machine learning models in a standalone Python application.
- [x] Kubernetes([GKE](https://cloud.google.com/kubernetes-engine)) | [Blog post from 🤗](https://huggingface.co/blog/deploy-tfserving-kubernetes)
  - We cover how to build a custom TensorFlow Serving Docker image with 🤗 Transformers' ViT model, provision GKE cluster, deploy the Docker image to the GKE cluster.
  - Particularly, we cover Kubernetes specific topics such as creating Deployment/Service/HPA Kubernetes objects for scalable deployment of the Docker image to the nodes(VMs) and expose them as a service to clients.
  - With this, you will be able to serve and scale your own machine learning models according to the CPU utilizations of the deployment as a whole.
- [x] [Vertex AI Prediction](https://cloud.google.com/vertex-ai/docs/predictions/getting-predictions) 
  - We cover how to deploy 🤗 Transformers' ViT model to Google Cloud's fully managed machine learning deployment service (Vertex AI Prediction). 
  - Under the hood, Vertex AI Prediction leverages all the technologies from GKE, TensorFlow Serving, and more. 
  - That means you can deploy and scale the deployment of machine learning models, but you don't need to worry to make it happened from building a custom Docker image to writing Kubernetes specific menifests to setting up model monitoring capability.
  - With this, you will be able to serve and scale your own machine learning model by calling various APIs from `google-cloud-aiplatform` SDK to interact with Vertex AI. 

- [ ] Vertex AI Prediction (w/ [optimized TFRT](https://cloud.google.com/vertex-ai/docs/predictions/optimized-tensorflow-runtime))
  - TBD

Know more about the optimized TFRT(TensorFlow RunTime) [here](https://github.com/tensorflow/runtime).

