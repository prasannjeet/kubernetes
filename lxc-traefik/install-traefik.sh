#!/bin/bash

snap install helm --classic
helm repo add traefik https://helm.traefik.io/traefik
cd / && helm upgrade --install traefik traefik/traefik \
   --values=values.yaml \
   --namespace cattle-system \
   --set service.type="ClusterIP"