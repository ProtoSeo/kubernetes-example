#!/bin/sh

#
swapoff -a
sed -i.bak -r 's/(.+\s*swap\s*.+)/#\1/' /etc/fstab

# 
cat >> /etc/hosts <<EOF
192.168.1.150 lb
192.168.1.100 lb1
192.168.1.200 lb2
192.168.1.101 master1
192.168.1.102 master2
192.168.1.103 master3
192.168.1.201 worker1
192.168.1.202 worker2
EOF

#
dpkg -i ./docker/*.deb

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
FILES="./image/*.tar"
for f in $FILES
do
    docker load < $f
done

#
dpkg -i ./debfile/*.deb

#
CNI_VERSION="v0.8.2" 
ARCH="amd64" 
mkdir -p /opt/cni/bin 
tar -C /opt/cni/bin -xzf ./k8s/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz

DOWNLOAD_DIR=/usr/local/bin
mkdir -p $DOWNLOAD_DIR

CRICTL_VERSION="v1.22.0"
tar -C $DOWNLOAD_DIR -xzf ./k8s/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz

cp ./k8s/kubelet ./k8s/kubeadm ./k8s/kubectl $DOWNLOAD_DIR
chmod +x $DOWNLOAD_DIR/kubeadm
chmod +x $DOWNLOAD_DIR/kubelet
chmod +x $DOWNLOAD_DIR/kubectl

sed "s:/usr/bin:${DOWNLOAD_DIR}:g" ./k8s/kubelet.service | sudo tee /etc/systemd/system/kubelet.service

mkdir -p /etc/systemd/system/kubelet.service.d

sed "s:/usr/bin:${DOWNLOAD_DIR}:g" ./k8s/10-kubeadm.conf | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl enable --now kubelet
