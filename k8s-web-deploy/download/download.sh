#!/bin/sh

mkdir web-deploy
cd ./web-deploy

docker pull mysql:5.7
docker save mysql:5.7 -o mysql57.tar

docker pull protoseo/ktor-practice:v0.0.1
docker save protoseo/ktor-practice:v0.0.1 -o ktor-practice.tar

docker pull gcr.io/google-samples/xtrabackup:1.0
docker save gcr.io/google-samples/xtrabackup:1.0 -o xtrabackup.tar

docker pull k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2
docker save k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2 -o provisioner.tar

## 1.24 <= kubernetes version : ctr -n=k8s.io images import ktor-practice.tar
## 1.24 > kubernetes version : docker load -i ktor-practice.tar