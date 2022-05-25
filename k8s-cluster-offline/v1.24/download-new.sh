#!/bin/sh

if [ $(id -u) -ne 0 ]
then
  echo "This script must be run as root"
  exit
fi

curl -fsSL https://get.docker.com | sudo sh

mkdir cluster
cd ./cluster

DOCKER_PATH="./docker"
CONTAINERD="1.6.4-1"
DOCKER="20.10.16~3-0"
DOCKER_SCAN="0.17.0"
DOCKER_COMPOSE="2.5.0"

curl -L -O "https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/containerd.io_${CONTAINERD}_amd64.deb"
curl -L -O "https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce-rootless-extras_${DOCKER}~ubuntu-focal_amd64.deb"
curl -L -O "https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce-cli_${DOCKER}~ubuntu-focal_amd64.deb"
curl -L -O "https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce_${DOCKER}~ubuntu-focal_amd64.deb"
curl -L -O "https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-scan-plugin_${DOCKER_SCAN}~ubuntu-focal_amd64.deb"
curl -L -O "https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-compose-plugin_${DOCKER_COMPOSE}~ubuntu-focal_amd64.deb"
mkdir $DOCKER_PATH
mv ./*.deb $DOCKER_PATH

K8S_PATH="./k8s"
ARCH="amd64"
CNI_VERSION="v0.8.2"
CRICTL_VERSION="v1.22.0"
RELEASE="v1.24.0" # "$(curl -sSL https://dl.k8s.io/release/stable.txt)"
RELEASE_VERSION="v0.4.0"

curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz" -o cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz
curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" -o crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz
curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/${ARCH}/{kubeadm,kubelet,kubectl}
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | cat > kubelet.service
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | cat > 10-kubeadm.conf

mkdir $K8S_PATH
mv kube* c* 10-kubeadm.conf $K8S_PATH

DEB_PATH="./debfile"
curl -L -O "http://archive.ubuntu.com/ubuntu/pool/main/e/ethtool/ethtool_5.4-1_amd64.deb"
curl -L -O "http://archive.ubuntu.com/ubuntu/pool/main/c/conntrack-tools/conntrack_1.4.5-2_amd64.deb"
curl -L -O "http://archive.ubuntu.com/ubuntu/pool/main/s/socat/socat_1.7.3.3-2_amd64.deb"
mkdir $DEB_PATH
mv ./*.deb $DEB_PATH

IMAGE_PATH="./image"
API_SERVER="v1.24.0"
CONTROLLER="v1.24.0"
SCHEDULER="v1.24.0"
PROXY="v1.24.0"
PAUSE="3.7"
ETCD="3.5.3-0"
COREDNS="v1.8.6"
CALICO="v3.23.1"

ctr image pull k8s.gcr.io/kube-apiserver:$API_SERVER
ctr image pull k8s.gcr.io/kube-controller-manager:$CONTROLLER
ctr image pull k8s.gcr.io/kube-scheduler:$SCHEDULER
ctr image pull k8s.gcr.io/kube-proxy:$PROXY
ctr image pull k8s.gcr.io/pause:$PAUSE
ctr image pull k8s.gcr.io/etcd:$ETCD
ctr image pull k8s.gcr.io/coredns/coredns:$COREDNS
ctr image pull docker.io/calico/cni:$CALICO
ctr image pull docker.io/calico/pod2daemon-flexvol:$CALICO
ctr image pull docker.io/calico/node:$CALICO
ctr image pull docker.io/calico/kube-controllers:$CALICO

ctr image export kube-apiserver.tar k8s.gcr.io/kube-apiserver:$API_SERVER
ctr image export kube-controller-manager.tar k8s.gcr.io/kube-controller-manager:$CONTROLLER
ctr image export kube-scheduler.tar k8s.gcr.io/kube-scheduler:$SCHEDULER
ctr image export kube-proxy.tar k8s.gcr.io/kube-proxy:$PROXY
ctr image export pause.tar k8s.gcr.io/pause:$PAUSE
ctr image export etcd.tar k8s.gcr.io/etcd:$ETCD
ctr image export coredns.tar k8s.gcr.io/coredns/coredns:$COREDNS
ctr image export calico-cni.tar docker.io/calico/cni:$CALICO
ctr image export calico-pod2daemon-flexvol.tar docker.io/calico/pod2daemon-flexvol:$CALICO
ctr image export calico-node.tar docker.io/calico/node:$CALICO
ctr image export calico-kube-controllers.tar docker.io/calico/kube-controllers:$CALICO
mkdir $IMAGE_PATH
mv ./*.tar $IMAGE_PATH

CALICO_PATH="./calico"
curl -L -O "https://projectcalico.docs.tigera.io/manifests/calico.yaml"
mkdir $CALICO_PATH
mv ./*.yaml $CALICO_PATH