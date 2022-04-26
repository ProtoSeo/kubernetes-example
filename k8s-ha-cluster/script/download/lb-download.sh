#!/bin/sh

HAPROXY_PATH="./haproxy"
apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests \
  --no-conflicts --no-breaks --no-replaces --no-enhances \
  --no-pre-depends "haproxy" | grep "^\w")
mkdir $HAPROXY_PATH
mv ./*.deb $HAPROXY_PATH

KEEPALIVED_PATH="./keepalived"
apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests \
  --no-conflicts --no-breaks --no-replaces --no-enhances \
  --no-pre-depends "keepalived" | grep "^\w")
mkdir $KEEPALIVED_PATH
mv ./*.deb $KEEPALIVED_PATH