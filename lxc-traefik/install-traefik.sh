#!/bin/bash

snap install helm --classic
cd / && helm upgrade --install traefik traefik/traefik \
   --values=values.yaml \
   --namespace traefik \
   --set service.type="ClusterIP"