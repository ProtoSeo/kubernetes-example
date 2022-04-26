#!/bin/sh

NFS_SERVER_PATH="./nfs-kernel-server"
apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests \
  --no-conflicts --no-breaks --no-replaces --no-enhances \
  --no-pre-depends "nfs-kernel-server" | grep "^\w")
mkdir $NFS_SERVER_PATH
mv ./*.deb $NFS_SERVER_PATH

NFS_COMMON_PATH="./nfs-common"
apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests \
  --no-conflicts --no-breaks --no-replaces --no-enhances \
  --no-pre-depends "nfs-common" | grep "^\w")
mkdir $NFS_COMMON_PATH
mv ./*.deb $NFS_COMMON_PATH