#!/bin/bash
sudo kubeadm reset --force --cleanup-tmp-dir
sudo rm -rf  ~/.kube
sudo rm -rf /etc/cni/net.d/*
sudo rm -rf $HOME/.kube/config
sudo rm -rf /var/lib/etcd
sudo mv /etc/containerd/config.toml /root/config.toml.bak
sudo systemctl restart containerd
sudo ip link set cni0 down && sudo ip link delete cni0
sudo systemctl stop apparmor
sudo systemctl disable apparmor
sudo systemctl restart containerd.service
sudo apt remove --purge -y kubelet kubeadm kubectl docker go* --allow-change-
set -eu pipefail
sudo apt remove --purge -y software-properties-common curl apt-transport-http
sudo rm -f /etc/modules-load.d/k8s.conf
# sysctl params required by setup, params persist across reboots
sudo rm -f /etc/sysctl.d/k8s.conf
# Removing CRI-O Runtime from All the Nodes.............................
sudo rm -f /etc/apt/keyrings/cri-o-apt-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/cri-o.list
sudo apt remove --purge -y cri-o* --allow-change-held-packages
# remove Kubeadm & Kubelet & Kubectl on all Nodes..........
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
#sudo apt-mark unhold kubelet=1.29.0-1.1 kubeadm=1.29.0-1.1 kubectl=1.29.0-1.
sudo apt-mark unhold kubelet* kubeadm* kubectl*
sudo apt remove --purge -y kubeadm* kubelet* kubectl* --allow-change-held-pac
# For removal of docker and containerd conflict pkgs
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docke
sudo apt-get clean
sudo apt-get autoclean
sudo apt-get autoremove
sudo dpkg --purge `COLUMNS=300 dpkg -l "*" | egrep "^rc" | cut -d\  -f3`

