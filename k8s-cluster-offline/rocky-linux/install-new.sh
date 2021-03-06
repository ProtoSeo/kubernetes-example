#!/bin/sh

if [ $(id -u) -ne 0 ]
then
  echo "This script must be run as root"
  exit
fi

# Check node type
if [[ $1 != "--master" ]] && [[ $1 != "--worker" ]]
then
    echo "Please specify the node type: --master or --worker"
    exit 1
fi

## 메모리 스왑 OFF
swapoff -a
sed -i.bak -r 's/(.+\s*swap\s*.+)/#\1/' /etc/fstab

# permissive 모드로 SELinux 설정(효과적으로 비활성화)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

## VM 설정에 맞도록 변경
cat >> /etc/hosts <<EOF
192.168.1.210 master
192.168.1.220 worker1
192.168.1.230 worker2
EOF

## CRICTL 설정 파일 미리 생성
cat >> /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 2
pull-image-on-create: false
EOF

## overlay, br_netfilter 모듈 등록
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# 필요한 sysctl 파라미터를 설정하면 재부팅 후에도 유지된다.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system # 재부팅하지 않고 sysctl 파라미터 적용

## 방화벽 설정
if [[ $1 = "--master" ]]
then
    firewall-cmd --permanent --add-port={179,6443,2379,2380,10250,10257,10259}/tcp
    firewall-cmd --reload
fi

if [[ $1 = "--worker" ]]
then
    firewall-cmd --permanent --add-port={179,10250,30000-32767}/tcp
    firewall-cmd --reload
fi

## containerd 설치
rpm -ivh --replacefiles --replacepkgs containerd/*.rpm

## containerd 설정
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sed -i 's$sandbox_image = "k8s.gcr.io/pause:3.6"$sandbox_image = "k8s.gcr.io/pause:3.7"$g' /etc/containerd/config.toml
systemctl enable --now containerd
systemctl restart containerd

## 사전에 필요한 이미지 파일 압축 해제
FILES="./image/*.tar"
for f in $FILES;do ctr -n=k8s.io images import $f;done

## 쿠버네티스 설치에 필요한 의존성 
rpm -ivh --replacefiles --replacepkgs rpm/*.rpm

## 쿠버네티스 설치 
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

##### Example #####

## Master Node
## sudo kubeadm init --apiserver-advertise-address=192.168.1.110 --pod-network-cidr 172.16.0.0/16
## mkdir -p $HOME/.kube
## sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
## sudo chown $(id -u):$(id -g) $HOME/.kube/config

## Worker Node
## kubeadm join 192.168.1.110:6443 --token lqh61d.cw3sqb4b89kqrrye \
##      --discovery-token-ca-cert-hash sha256:c3ed6f7d1e467ede7e6a3f100a1898533457d50459cffc51a7f3257ecaf0e3b3 