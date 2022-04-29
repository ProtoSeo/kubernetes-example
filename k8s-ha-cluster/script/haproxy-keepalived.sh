#!/bin/sh

if [[ $1 != "master" && $1 != "backup" ]] 
then
echo "please input \"master\" or \"backup\""
exit 1
fi

cat >> /etc/hosts <<EOF
192.168.1.150 lb
192.168.1.100 lb1
192.168.1.200 lb2
192.168.1.101 master1
192.168.1.102 master2
192.168.1.103 master3
192.168.1.201 worker1
192.168.1.202 worker2
EOF

dpkg -i ./haproxy/*.deb
dpkg -i ./keepalived/*.deb

if [ $1 == "master" ]
then
## MASTER
cat >> /etc/keepalived/keepalived.conf << EOF
! /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
    router_id LVS_DEVEL
}

vrrp_script check_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface enp0s8
    virtual_router_id 50
    priority 100
    authentication {
        auth_type PASS
        auth_pass 42
    }
    virtual_ipaddress {
        192.168.1.150
    }
    track_script {
        check_apiserver
    }
}
EOF
fi

if [ $1 == "backup" ]
then
## BACKUP
cat >> /etc/keepalived/keepalived.conf << EOF
! /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
    router_id LVS_DEVEL
}

vrrp_script check_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state BACKUP
    interface enp0s8
    virtual_router_id 50
    priority 99
    authentication {
        auth_type PASS
        auth_pass 42
    }
    virtual_ipaddress {
        192.168.1.150
    }
    track_script {
        check_apiserver
    }
}
EOF
fi

cat >> /etc/keepalived/check_apiserver << EOF
#!/bin/sh

APISERVER_DEST_PORT=26443
APISERVER_VIP=192.168.1.150

errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

curl --silent --max-time 2 --insecure https://localhost:${APISERVER_DEST_PORT}/ -o /dev/null || errorExit "Error GET https://localhost:${APISERVER_DEST_PORT}/"
if ip addr | grep -q ${APISERVER_VIP}; then
    curl --silent --max-time 2 --insecure https://${APISERVER_VIP}:${APISERVER_DEST_PORT}/ -o /dev/null || errorExit "Error GET https://${APISERVER_VIP}:${APISERVER_DEST_PORT}/"
fi
EOF

cat >> /etc/haproxy/haproxy.cfg << EOF
frontend kubernetes-master-lb
    bind 0.0.0.0:26443
    mode tcp
    option tcplog
    default_backend kubernetes-master-nodes

backend kubernetes-master-nodes
    mode tcp
    balance roundrobin
    option tcp-check
    option tcplog
    server master1 192.168.1.101:6443 check
    server master2 192.168.1.102:6443 check
    server master3 192.168.1.103:6443 check
EOF

systemctl enable keepalived --now
systemctl enable haproxy --now
systemctl restart keepalived
systemctl restart haproxy