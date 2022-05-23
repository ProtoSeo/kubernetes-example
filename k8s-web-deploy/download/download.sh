#!/bin/sh

docker pull mysql:5.7
docker save mysql:5.7 > mysql.tar

docker pull protoseo/ktor-practice:v0.0.1
docker save protoseo/ktor-practice:v0.0.1 > ktor-practice.tar

docker pull gcr.io/google-samples/xtrabackup:1.0
docker save gcr.io/google-samples/xtrabackup:1.0 > xtrabackup.tar

docker pull k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2
docker save k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2 > provisioner.tar