# 오프라인 환경에서 쿠버네티스 고가용성 클러스터 구축하기

## 목표
1. 쿠버네티스 고가용성 클러스터 구축
2. 로드밸런서 이중화를 통해 SPOF 위험 줄이기
3. kubernetes-dashboard 적용하기
4. prometheus + grafana 적용해서 모니터링 툴 적용하기

## 가상머신 환경

Oracle VirtualBox 사용

### 상세 가상머신 설정
|VM Name|IP|CPU|RAM|Disk|Role|
|-|-|-|-|-|-|
|master1|192.168.1.101|2|2048MB|15GB|Master, etcd|
|master2|192.168.1.102|2|2048MB|15GB|Master, etcd|
|master3|192.168.1.103|2|2048MB|15GB|Master, etcd|
|worker1|192.168.1.201|2|2048MB|15GB|Worker, NFS Client|
|worker2|192.168.1.202|2|2048MB|15GB|Worker, NFS Client|
|lb1|192.168.1.100|1|1024MB|10GB|HAProxy, Keepalived|
|lb2|192.168.1.200|1|1024MB|10GB|HAProxy, Keepalived|
|nfs|192.168.1.50|1|1024MB|10GB|NFS Server|
|network|192.168.1.10|1|1024MB|15GB|설치 파일 다운로드|

## 최종환경
![최종환경](./image/%EC%B5%9C%EC%A2%85%ED%99%98%EA%B2%BD.PNG)
## 사전 준비작업 (Network 가상머신)
아래의 script를 통해서 다운로드를 받은 뒤, scp를 활용해서 필요한 가상머신에 전송한다.

1. `download.sh`
    - docker, kubernetes 설치 관련 설치 파일 / 도커 이미지를 다운로드 후 master, worker node 가상머신으로 옮긴다.
    - `none-install.sh`를 master, worker node 가상머신에서 root 권한으로 실행시켜서 간편하게 설치할 수 있다.
2. `lb-download.sh` 
    - loadbalancer 설치 관련 설치 파일 다운로드 후, lb 가상머신으로 옮긴다.
    - `haproxy-keepalived.sh`를 lb1, lb2 가상머신에서 root 권한으로 실행시켜서 간편하게 설치할 수 있다.
3. `dashboard-download.sh`
    - kubernetes-dashboard 설치 관련 도커 이미지 다운로드, 다운로드 후 worker node 가상머신으로 옮긴다.
4. `nfs-download.sh`
    - nfs서버, nfs클라이언트를 구성하기 위한 설치파일 다운로드 후, 서버 설치 파일은 nfs 가상머신, 클라이언트 설치 파일은 Worker node 가상머신으로 옮긴다.
5. `monitoring-download.sh`
    - monitoring tool 도커 이미지 다운로드 후, worker node 가상머신으로 옮긴다.
    - `node-exporter.tar`은 master node 가상머신에도 옮긴다.

## 간단한 설치 방법
> 설치 파일, 도커 이미지가 모두 준비되어 있다고 가정한다.   
상세한 설치 방법은 발표자료를 참고한다.

1. 로드밸런서 구축
    1. Network 가상머신을 통해서 받은 HAProxy, Keepalived 설치 파일을 설치한다.
    2. `/etc/hosts`에 가상머신 IP들을 로컬 도메인으로 등록한다.
    3. `/etc/haproxy/haproxy.cfg`파일을 수정한다.
    4. lb1, lb2 가상머신의 `/etc/keepalived/keepalived.conf`파일을 각각 수정한다. (없으면 생성해서 작성한다.)
    5. 설정을 반영한 다음 HAProxy, Keepalived를 restart한 다음 status를 확인한다.
2. 고가용성 클러스터 구축
    1. master node 하나에서 클러스터를 초기화 한다.
    2. CNI를 추가한다.(Calico를 사용하였다.)
    3. 나머지 master node를 초기화된 클러스터에 Join한다.
    4. worker node들을 초기화된 클러스터에 join한다.
3. kubernetes dashboard 적용
    1. 준비된 도커 이미지 압축파일을 압축을 풀어서 도커 이미지화 한다.
    2. `kube-dashboard.yaml` 실행
    3. `dashboard-adminuser.yaml` 실행
    4. `metrics-server.yaml` 실행
4. 모니터링 툴(Prometheus, Grafana) 적용
    1. 준비된 도커 이미지 압축파일을 압축을 풀어서 도커 이미지화 한다.
    2. `/grafana` 실행
    3. `/prometheus` 실행
    4. `/kube-state-metrics` 실행