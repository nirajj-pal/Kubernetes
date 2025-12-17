#!/usr/bin/env bash
set -euo pipefail


if [ "$EUID" -ne 0 ]; then
echo "Run as root"
exit 1
fi


# Optional: source vars if present next to the script
[ -f ./00-vars.sh ] && source ./00-vars.sh


echo "== Update packages and install prerequisites =="
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common sshpass


echo "== Disable swap =="
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab || true


echo "== Load kernel modules =="
cat > /etc/modules-load.d/k8s.conf <<'EOF'
overlay
br_netfilter
EOF


modprobe overlay || true
modprobe br_netfilter || true


cat > /etc/sysctl.d/99-k8s.conf <<'EOF'
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system


echo "== Install containerd =="
apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
# Use systemd cgroup driver
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml || true
systemctl restart containerd
systemctl enable containerd


echo "== Install kubeadm, kubelet, kubectl =="
# Install trusted keyring dir
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg


echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
| tee /etc/apt/sources.list.d/kubernetes.list


apt-get update -y
apt-get install -y kubeadm=${K8S_VERSION:-1.30.14-00} kubelet=${K8S_VERSION:-1.30.14-00} kubectl=${K8S_VERSION:-1.30.14-00}
apt-mark hold kubeadm kubelet kubectl || true
systemctl enable kubelet


echo "== Common setup complete =="
