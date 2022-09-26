#!/bin/bash

# This script has been tested on Ubuntu 20.04
# For other versions of Ubuntu, you might need some tweaking

#######################################
# To be executed only on master nodes #
#######################################

if [[ $(hostname) =~ .*master.* ]]
then

  echo "[TASK 7] Pull required containers"
  kubeadm config images pull >/dev/null 2>&1

  echo "[TASK 8] Initialize Kubernetes Cluster"
  rm /etc/containerd/config.toml
  systemctl restart containerd
  # kubeadm init --control-plane-endpoint="192.168.0.5:53" --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all >> /root/kubeinit.log
  kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all >> /root/kubeinit.log

  echo "[TASK 9] Copy kube admin config to root user .kube directory"
  mkdir /root/.kube
  cp /etc/kubernetes/admin.conf /root/.kube/config  

  echo "[TASK 10] Deploy Flannel network"
  # kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  su ubuntu
  sleep 35
  # kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=1.25.2"
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

  echo "[TASK 11] Generate and save cluster join command to /joincluster.sh"
  joinCommand=$(kubeadm token create --print-join-command 2>/dev/null) 
  echo "$joinCommand --ignore-preflight-errors=all" > /joincluster.sh

fi

#######################################
# To be executed only on worker nodes #
#######################################

if [[ $(hostname) =~ .*worker.* ]]
then
  echo "[TASK 7] Join node to Kubernetes Cluster"
  apt install -qq -y sshpass >/dev/null 2>&1
  sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster.lxd:/joincluster.sh /joincluster.sh 2>/tmp/joincluster.log
  bash /joincluster.sh >> /tmp/joincluster.log 2>&1
fi
