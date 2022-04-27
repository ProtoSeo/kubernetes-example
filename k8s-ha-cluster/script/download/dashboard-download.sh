#!/bin/sh

# download
DASHBOARD_PATH="./dashboard"
METRICS="v1.0.7"
DASHBOARD="v2.5.1"
MERTRICS_SERVER="v0.6.1"

docker pull kubernetesui/metrics-scraper:$METRICS
docker pull kubernetesui/dashboard:$DASHBOARD
docker pull k8s.gcr.io/metrics-server/metrics-server:$MERTRICS_SERVER

docker save kubernetesui/metrics-scraper:$METRICS > metrics-scraper.tar
docker save kubernetesui/dashboard:$DASHBOARD > dashboard.tar
docker save k8s.gcr.io/metrics-server/metrics-server:$MERTRICS_SERVER > metrics-server.tar

mkdir $DASHBOARD_PATH
mv ./*.tar $DASHBOARD_PATH