# 모니터링 툴 설치

## 실행 방법
> 먼저 Worker node에 monitoring 관련 docker image가 준비되어 있어야 한다.   
`script/download` 디렉토리의 `monitoring-download.sh` 스크립트를 통해서 다운로드 받을 수 있다.

먼저 monitoring `namespace`를 생성한다.
```bash
kubectl create ns monitoring
```

이후 해당 yaml 파일들을 실행한다.
```bash
kubectl apply -f grafana/
kubectl apply -f prometheus/
kubectl apply -f kube-state-metrics/
```

## 설명
### Grafana
메트릭과 로그를 모니터링하고 분석할 수 있도록 도와주는 시각화 및 분석 도구이다.

> [Deploy Grafana on Kubernetes](https://grafana.com/docs/grafana/latest/installation/kubernetes)에서 yaml파일 참고 

- `grafana-deployment.yaml`
  - grafana를 Pod로 배포하는 deployment
- `grafana-pv.yaml`
  - grafana의 데이터를 nfs에 저장하기 위한 pv
- `grafana-pvc.yaml`
  - grafana Pod와 생성한 pv랑 연결하기 위한 pvc
- `grafana-svc.yaml`
  - 생성한 grafana Pod를 외부에 노출하기 위한 Service

### Prometheus
메트릭 수집과 시각화, 알림 서비스를 제공하는 오픈소스 모니터링 툴킷이다.

> [Kubernetes Monitoring - Prometheus 실습](https://gruuuuu.github.io/cloud/monitoring-02) 블로그 참고

- `prometheus-cluster-role.yaml`
  - prometheus 컨테이너가 쿠버네티스 API에 접근할 수 있는 권한을 부여하는 cr과 crb
- `prometheus-cm.yaml`
  - prometheus를 기동하기 위해 필요한 환경 설정파일을 정의하기 위한 cm
- `prometheus-deployment.yaml`
  - prometheus를 Pod로 배포하는 deployment
- `prometheus-svc.yaml`
  - 생성한 prometheus Pod를 외부에 노출하기 위한 service
- `prometheus-pv.yaml`
  - prometheus 데이터를 nfs에 저장하기 위한 pv
- `prometheus-pvc.yaml`
  - prometheus Pod와 생성한 pv랑 연결하기 위한 pvc

### Node-exporter
하드웨어와 OS의 시스템 메트릭을 수집하는 exporter이다.

- `prometheus-node-exporter.yaml`
  - node-exporter를 Pod로 배포하기 위한 DaemonSet
    - node-exporter는 모든 노드에서 실행되어야 하므로 DaemonSet으로 구성한다.
  - node-exporter에 내부에서 접속하기 위한 service

### Kube-state-metrics
쿠버네티스 클러스터의 다양한 오브젝트(Deployment, Node, Pod, ...)의  상태에 대한 메트릭 정보를 생성하고, 이를 HTTP 엔드포인트를 통해 제공한다.

> [Standard install example on k8s - kube-state-metrics Github](https://github.com/kubernetes/kube-state-metrics/tree/master/examples/standard) 에서 제공하는 yaml 파일 사용

## 참고자료
> [Grafana docs](https://grafana.com/docs/grafana/latest/)   
[Prometheus docs](https://prometheus.io/docs/prometheus/latest/)   
[kube-state-metrics github](https://github.com/kubernetes/kube-state-metrics)   
[node_exporter github](https://github.com/prometheus/node_exporter)   
[Kubernetes Monitoring - Prometheus 실습](https://gruuuuu.github.io/cloud/monitoring-02)
