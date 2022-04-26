#!/bin/sh

MONITORING_PATH="./monitoring"

# download grafana
GRAFANA="8.4.4"

docker pull grafana/grafana:$GRAFANA
docker save grafana/grafana:$GRAFANA > grafana.tar

# download kube-state-metrics

KUBE_STATE_METRICS="v2.4.2"
docker pull k8s.gcr.io/kube-state-metrics/kube-state-metrics:$KUBE_STATE_METRICS
docker save k8s.gcr.io/kube-state-metrics/kube-state-metrics:$KUBE_STATE_METRICS > kube-state-metrics.tar

# download prometheus
PROMETHEUS="v2.34.0"
NODE_EXPORTER="v1.3.1"

docker pull prom/prometheus:$PROMETHEUS
docker pull prom/node-exporter:$NODE_EXPORTER
docker save prom/prometheus:$PROMETHEUS > prometheus.tar
docker save prom/node-exporter:$NODE_EXPORTER > node-exporter.tar

# download node_exporter
curl -L -O "https://github.com/prometheus/node_exporter/releases/download/${NODE_EXPORTER}/node_exporter-1.3.1.linux-amd64.tar.gz"

mkdir $MONITORING_PATH
mv ./*.tar ./*.tar.gz $MONITORING_PATH