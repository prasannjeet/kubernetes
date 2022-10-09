#!/bin/bash

apt install nfs-kernel-server nfs-common rpcbind -y
mkdir /home/pj/nfs && mkdir /home/pj/nfs/public
chmod 777 /home/pj/nfs/public
# echo '/home/pj/nfs/public *(rw,sync,no_subtree_check)' >> /etc/exports
echo '/home/pj/nfs/public *(rw,sync,no_subtree_check)' | sudo tee -a /etc/exports
# sudo ufw allow nfs
# sudo ufw allow from [clientIP or clientSubnetIP] to any port nfs
sudo exportfs -a
sudo systemctl restart nfs-kernel-server