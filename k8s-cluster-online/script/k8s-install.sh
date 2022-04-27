#!/bin/sh

swapoff -a
sed -i.bak -r 's/(.+\s*swap\s*.+)/#\1/' /etc/fstab

#
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2" 
} 
EOF

systemctl daemon-reload
systemctl restart docker

#
cat >> /etc/hosts <<EOF
192.168.1.100 lb1
192.168.1.200 lb2
192.168.1.101 master1
192.168.1.102 master2
192.168.1.103 master3
192.168.1.201 worker1
192.168.1.202 worker2
EOF

#
apt-get update 
apt-get install -y apt-transport-https ca-certificates curl

#
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

#
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#
apt-get update 
apt-get install -y kubelet kubeadm kubectl 
apt-mark hold kubelet kubeadm kubectl

#
free -m
cat /etc/fstab