#!/bin/bash

snap install helm --classic
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
kubectl create namespace cattle-system
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.7.1
helm install rancher rancher-stable/rancher --namespace cattle-system --set hostname=rancher.logicalguy.com --set bootstrapPassword=admin
kubectl -n cattle-system rollout status deploy/rancher