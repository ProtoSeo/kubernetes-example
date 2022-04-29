#!/bin/sh

VERSION="1.3.1"
DIR="/mnt/node_exporter"
mkdir -p $DIR
tar -xzvf node_exporter-$VERSION.linux-amd64.tar.gz
mv ./node_exporter-$VERSION.linux-amd64/* $DIR
rm -rf ./node_exporter-$VERSION.linux-amd64/

cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/mnt/node_exporter/node_exporter

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

systemctl status node_exporter