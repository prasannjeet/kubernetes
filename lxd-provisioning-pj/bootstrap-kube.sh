#!/bin/bash

# This script has been tested on Ubuntu 20.04
# For other versions of Ubuntu, you might need some tweaking

echo "[TASK 0] Install essential packages"
apt install -qq -y net-tools curl ssh software-properties-common 
apt-get install -qq -y linux-image-$(uname -r) 

echo "[TASK 1] Install containerd runtime"
apt update -qq 
apt install -qq -y containerd apt-transport-https 
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd 

echo "[TASK 2] Add apt repo for kubernetes"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - 
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" 

echo "[TASK 3] Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt install -qq -y kubeadm=1.25.2-00 kubelet=1.25.2-00 kubectl=1.25.2-00 
echo 'KUBELET_EXTRA_ARGS="--fail-swap-on=false"' > /etc/default/kubelet

# Some tweaks to ensure vm works (--insecure-skip-tls-verify)
swapoff -a
echo overlay >> /etc/modules

echo '#!/bin/sh -e
mount --make-rshared /' > /etc/rc.local
mkdir /run/flannel
touch /run/flannel/subnet.env
echo 'FLANNEL_NETWORK=10.244.0.0/16
FLANNEL_SUBNET=10.244.0.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true' > /run/flannel/subnet.env

touch /etc/crictl.yaml
echo 'runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: false' > /etc/crictl.yaml

sysctl net.bridge.bridge-nf-call-iptables=1

sed -i '1s/^/[Unit]\nDescription=Kubernetes\nAfter=syslog.target\nAfter=network.target\n/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

cat > /etc/sysctl.d/k8s-ipv6.conf <<EOF
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
EOF
sysctl --system
systemctl daemon-reload
systemctl restart containerd
# Tweaks end

systemctl restart kubelet

echo "[TASK 4] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo "[TASK 5] Set root password"
echo -e "kubeadmin\nkubeadmin" | passwd root 
echo "export TERM=xterm
alias k='kubectl -n kube-system'" >> /etc/bash.bashrc

echo "[TASK 6] Install additional packages"
apt install -qq -y net-tools 