#!/usr/bin/env bash
# Default variables (matches your /etc/hosts)
BASTION_HOST="bastion" # 172.16.141.2
MASTER1_HOST="master01" # 172.16.141.3
MASTER2_HOST="master02" # 172.16.141.4
MASTER3_HOST="master03" # 172.16.141.5
WORKER1_HOST="worker01" # 172.16.141.6
WORKER2_HOST="worker02" # 172.16.141.7
WORKER3_HOST="worker03" # 172.16.141.8


# Kubernetes apt repo version (change if you want different minor)
K8S_VERSION="1.30.14-00"
POD_NETWORK_CIDR="10.244.0.0/16" # Flannel default


# HAProxy bind port
API_SERVER_PORT=6443
