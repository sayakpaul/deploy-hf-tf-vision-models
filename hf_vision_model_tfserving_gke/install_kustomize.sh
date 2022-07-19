#! /bin/sh

cd .kube
curl -sfLo kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.1.2/kustomize_v4.1.2_linux_amd64.tar.gz
tar -zxvf kustomize.tar.gz
rm kustomize.tar.gz
chmod u+x ./kustomize