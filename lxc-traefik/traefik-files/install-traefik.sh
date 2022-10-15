#!/bin/bash

helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm upgrade --install traefik traefik/traefik \
   --values=values_pj.yaml \
   --namespace traefik


