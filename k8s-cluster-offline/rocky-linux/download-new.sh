#!/bin/sh

if [ $(id -u) -ne 0 ]
then
  echo "This script must be run as root"
  exit
fi

mkdir cluster
cd ./cluster

## 설치에 필요한 파일부터 다운로드 받는다.
dnf install epel-release yum-utils -y

## docker 관련 다운로드를 받기 위한 repository 추가
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

## containerd 다운로드
CONTAINERD_PATH="./containerd"
CONTAINERD="1.6.4"

dnf download -y containerd.io-$CONTAINERD --resolve 

mkdir $CONTAINERD_PATH
mv ./*.rpm $CONTAINERD_PATH

## kubernetes 관련 다운로드를 받기 위한 repository 추가
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

## kubernetes 관련 의존성 다운로드
RPM_PATH="./rpm"
KUBE="1.24.0"
dnf download -y kubeadm-$KUBE --resolve --disableexcludes=kubernetes
rm -f *1.24.1* *1.24.0* *cni*
# rm -f *1.24.1*

mkdir $RPM_PATH
mv ./*.rpm $RPM_PATH

## kubelet, kubeadm, kubectl 다운로드
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
mv kube* cni* cri* 10-kubeadm.conf $K8S_PATH

## 이미지 다운로드를 위한 docker 설치
dnf install docker-ce -y
systemctl start docker

## 이미지 다운로드
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

## CNI 관련 다운로드
CALICO_PATH="./calico"
curl -L -O "https://projectcalico.docs.tigera.io/manifests/calico.yaml"
mkdir $CALICO_PATH
mv ./*.yaml $CALICO_PATH