#!/bin/bash

kubectl create namespace cattle-system

kubectl apply -f rancher-files/nfs_volume_claim.yaml

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml

helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.7.1

helm upgrade --install rancher rancher-latest/rancher \
   --set hostname=rancher.ooguy.com \
   --namespace cattle-system \
   --set replicas=3 \
   --set ingress.ingressClassName=traefik \
   --set customLogos.enabled=true \
   --set customLogos.volumeName=nfs-rancher-claim \
   --set customLogos.size=128Mi \
   --set bootstrapPassword=admin


kubectl -n cattle-system rollout status deploy/rancher


# helm upgrade --install rancher rancher-latest/rancher \
#    --set hostname=rancher.ooguy.com \
#    --namespace cattle-system \
#    --set replicas=3 \
#    --set ingress.ingressClassName=traefik \
#    --set ingress.tls.source=letsEncrypt \
#    --set letsEncrypt.email=prasannjeetsingh@gmail.com \
#    --set letsEncrypt.ingress.class=traefik \
#    --set customLogos.enabled=true \
#    --set customLogos.volumeName=nfs-rancher-claim \
#    --set customLogos.size=128Mi \
#    --set bootstrapPassword=admin