#!/bin/bash
sudo NEEDRESTART_MODE=a apt-get dist-upgrade --yes
sudo apt-mark unhold kubelet kubeadm kubectl
sudo apt clean -y
sudo apt-get clean -y
sudo apt update -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
#rm -rf /etc/apt/trusted.gpg.d/docker.gpg
if [ -f "/etc/apt/trusted.gpg.d/docker.gpg" ]; then
    # Remove the file
    rm -rf "/etc/apt/trusted.gpg.d/docker.gpg"
    echo "docker.gpg has been removed."
else
    echo "$docker.gpg does not exist."
fi
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
 
sudo apt update -y
sudo apt install -y containerd.io
 
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
 
sudo systemctl restart containerd
sudo systemctl enable containerd
 
sudo apt-get update -y
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
#rm -rf /etc/apt/keyrings/kubernetes-apt-keyring.gpg
if [ -f "/etc/apt/keyrings/kubernetes-apt-keyring.gpg" ]; then
    # Remove the file
    rm -rf "/etc/apt/keyrings/kubernetes-apt-keyring.gpg"
    echo "kubernetes-apt-keyring.gpg has been removed."
else
    echo "kubernetes-apt-keyring.gpgdoes not exist."
fi
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
 
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
 
sudo apt-get clean -y
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo kubeadm version