#!/bin/sh

curl -fsSL https://get.docker.com | sudo sh

mkdir noneNet
cd ./noneNet

DOCKER_PATH="./docker"
CONTAINERD="1.5.11-1"
DOCKER="20.10.14~3-0"
DOCKER_SCAN="0.17.0"
DOCKER_COMPOSE="2.3.3"

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
RELEASE="v1.23.6" # "$(curl -sSL https://dl.k8s.io/release/stable.txt)"
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
API_SERVER="v1.23.6"
CONTROLLER="v1.23.6"
SCHEDULER="v1.23.6"
PROXY="v1.23.6"
PAUSE="3.6"
ETCD="3.5.1-0"
COREDNS="v1.8.6"
CALICO="v3.22.2" # 아래의 calico.yaml image version을 따라야 한다.

docker pull k8s.gcr.io/kube-apiserver:$API_SERVER
docker pull k8s.gcr.io/kube-controller-manager:$CONTROLLER
docker pull k8s.gcr.io/kube-scheduler:$SCHEDULER
docker pull k8s.gcr.io/kube-proxy:$PROXY
docker pull k8s.gcr.io/pause:$PAUSE
docker pull k8s.gcr.io/etcd:$ETCD
docker pull k8s.gcr.io/coredns/coredns:$COREDNS
docker pull docker.io/calico/cni:$CALICO
docker pull docker.io/calico/pod2daemon-flexvol:$CALICO
docker pull docker.io/calico/node:$CALICO
docker pull docker.io/calico/kube-controllers:$CALICO

docker save k8s.gcr.io/kube-apiserver:$API_SERVER > kube-apiserver.tar
docker save k8s.gcr.io/kube-controller-manager:$CONTROLLER > kube-controller-manager.tar
docker save k8s.gcr.io/kube-scheduler:$SCHEDULER > kube-scheduler.tar
docker save k8s.gcr.io/kube-proxy:$PROXY > kube-proxy.tar
docker save k8s.gcr.io/pause:$PAUSE > pause.tar
docker save k8s.gcr.io/etcd:$ETCD > etcd.tar
docker save k8s.gcr.io/coredns/coredns:$COREDNS > coredns.tar
docker save docker.io/calico/cni:$CALICO > calico-cni.tar
docker save docker.io/calico/pod2daemon-flexvol:$CALICO > calico-pod2daemon-flexvol.tar 
docker save docker.io/calico/node:$CALICO > calico-node.tar
docker save docker.io/calico/kube-controllers:$CALICO > calico-kube-controllers.tar
mkdir $IMAGE_PATH
mv ./*.tar $IMAGE_PATH

CALICO_PATH="./calico"
curl -L -O "https://projectcalico.docs.tigera.io/manifests/calico.yaml"
mkdir $CALICO_PATH
mv ./*.yaml $CALICO_PATH
