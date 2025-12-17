#!/bin/bash
# Script: Kubernetes Master Node Setup
# Run this on each Master Node

set -e

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Load required kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configure sysctl parameters
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl --system

# Install dependencies
sudo apt update -y
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Add containerd repository

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
chmod 755 /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# Install containerd
sudo apt update
sudo apt install -y containerd.io


#Configure containerd to start using systemd as cgroup:

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml


#starting and enabling containerd
sudo systemctl restart containerd
sudo systemctl enable containerd


# Add Kubernetes repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
chmod 755 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Install kubeadm, kubelet, and kubectl
sudo apt update -y
sudo apt install -y kubelet kubeadm kubectl

# Mark Kubernetes packages to hold at the current version
sudo apt-mark hold kubelet kubeadm kubectl

# Ensure the apt package cache is up-to-date after installing the key
sudo apt update -y
sudo apt list --upgradable

 
