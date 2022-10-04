#!/bin/bash

snap install helm --classic
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
kubectl create namespace cattle-system
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.7.1
helm install rancher rancher/rancher:v2.7.0-rc3 --namespace cattle-system --set hostname=rancher.logicalguy.com --set bootstrapPassword=admin
# rancher/rancher:v2.7.0-rc3
# rancher-stable/rancher
kubectl -n cattle-system rollout status deploy/rancher