#!/bin/bash

mkdir /etc/containerd
cp ./config.toml /etc/containerd/config.toml
cp ./crictl.yaml /etc/crictl.yaml
mkdir /run/flannel
cp ./flannel_subnet.env /run/flannel/subnet.env
chmod +x ./bootstrap-kube.sh
sudo sh ./bootstrap-kube.sh
apt install -qq -y sshpass >/dev/null 2>&1
modprobe br_netfilter
swapoff -a
sysctl -w net.ipv4.ip_forward=1
kubeadm join 192.168.0.223:6443 --token tt889k.q1fv6jfkb6upznkt --discovery-token-ca-cert-hash sha256:15dc33c78ebcd036c84ad8b20e8a995a06c6568c29e57d98313a8124e9d6dcd3  --ignore-preflight-errors=all