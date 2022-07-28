# How to build CPU optimized TF Serving Docker image

This document shows how to build a CPU optimized TF Serving Docker image from source suitable for the target deployment hardware.

## Instructions (Within the target machine)

This instruction is for who aren't sure which instruction sets are supported in their target machine. It simplifies the [official document](https://github.com/tensorflow/serving/blob/master/tensorflow_serving/g3doc/setup.md) to show step-by-step instructions.

1. Prepare the target machine that you want to deploy TF Serving Docker image, and ssh into the machine.
2. Clone the [TF Serving repository](https://github.com/tensorflow/serving).
```
$ git clone https://github.com/tensorflow/serving.git
```
3. Go inside the repository folder.
```
$ cd serving
```
4. Build the base Docker image. This is going to build a CPU optimized Docker image of TensorFlow Core. If you run into the error `error: 'val.val' may be used uninitialized`, it can be ignored by `--copt=-Wno-error=maybe-uninitialized` since this is not the actual error but a sort of warnings.
```
$ tools/run_in_docker.sh bazel build \
    --config=nativeopt \
    --copt=-march=native \
    --copt=-Wno-error=maybe-uninitialized \
    tensorflow_serving/...
```
  - The previous step will build a `tensorflow/serving:nightly-devel` Docker image on your local machine. This is your platform-specific CPU-optimized TensorFlow/Core Docker image, and it is going to be the base image of the TF Serving.

5. Go inside the folder where the Dockerfile is.
```
$ cd tensorflow_serving/tools/docker
```

6. Update `Dockerfile` to use the CPU optimized Docker image as the base. Change the value of `TF_SERVING_VERSION` from `latest` to `tensorflow/serving:nightly-devel`
```
ARG TF_SERVING_VERSION=tensorflow/serving:nightly-devel
```

7. Build TF Serving Docker image. The command below is going to build a CPU optimized TF Serving image named as `tfserving:c2-avx512-nvvi-base`. For this project, we have used [`C2` instance](https://cloud.google.com/compute/docs/compute-optimized-machines#c2_machine_types) from Google Cloud, and the instance supports AVX512, FMA, and VNNI instruction sets. 
```
$ docker build -t tfserving:c2-avx512-nvvi-base -f Dockerfile .
```

  - For those of who want to use the custom built TF Serving image from this project, feel free to use it from `gcr.io/gcp-ml-172005/tfserving:c2-avx512-vnni-base`

