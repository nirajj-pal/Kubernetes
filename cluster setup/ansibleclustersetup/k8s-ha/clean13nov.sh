#!/usr/bin/env bash
# clean.sh - Reset Kubernetes & CNI state on this node
# Run as root (or via sudo)

set -euo pipefail

echo "[INFO] Stopping kubelet (if running)..."
sudo systemctl stop kubelet 2>/dev/null || true

echo "[INFO] Resetting kubeadm..."
sudo kubeadm reset --force --cleanup-tmp-dir || true

echo "[INFO] Removing kubeconfig and .kube directory..."
sudo rm -rf /etc/kubernetes
sudo rm -rf /var/lib/kubelet
sudo rm -rf $HOME/.kube
sudo rm -f  $HOME/.kube/config

echo "[INFO] Cleaning etcd data (safe on non-control-plane nodes too)..."
sudo rm -rf /var/lib/etcd || true

echo "[INFO] Cleaning CNI config and network interfaces..."
sudo rm -rf /etc/cni/net.d/* 2>/dev/null || true

# Tear down typical CNI interfaces if they exist
for iface in cni0 flannel.1 flannel.1-vxlan vxlan.calico tunl0 kube-ipvs0 docker0; do
  if ip link show "$iface" &>/dev/null; then
    echo "  - Deleting interface $iface"
    sudo ip link set "$iface" down || true
    sudo ip link delete "$iface" || true
  fi
done

echo "[INFO] Leaving AppArmor enabled (recommended). If you really need to disable it, do it manually."

echo "[INFO] Unholding Kubernetes packages (if held)..."
sudo apt-mark unhold kubelet kubeadm kubectl 2>/dev/null || true
sudo apt-mark unhold 'kubelet*' 'kubeadm*' 'kubectl*' 2>/dev/null || true

echo "[INFO] Removing Kubernetes packages..."
sudo apt remove --purge -y kubelet kubeadm kubectl 'kubelet*' 'kubeadm*' 'kubectl*' --allow-change-held-packages || true

echo "[INFO] Removing Kubernetes apt repo + keyring..."
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Optional: CRI-O cleanup, if you experimented with it
echo "[INFO] (Optional) Removing CRI-O bits, if present..."
sudo rm -f /etc/apt/keyrings/cri-o-apt-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/cri-o.list
sudo apt remove --purge -y 'cri-o*' --allow-change-held-packages 2>/dev/null || true

# Optional: remove container runtimes that might conflict
echo "[INFO] Removing conflicting container runtimes (docker.io / old containerd / runc)..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker runc; do
  sudo apt remove --purge -y "$pkg" 2>/dev/null || true
done

# If you want to ALSO wipe containerd itself (you usually don't need this), uncomment:
# echo "[INFO] Removing containerd packages..."
# sudo apt remove --purge -y 'containerd*' --allow-change-held-packages 2>/dev/null || true

echo "[INFO] Cleaning Kubernetes sysctl & modules config..."
sudo rm -f /etc/modules-load.d/k8s.conf
sudo rm -f /etc/sysctl.d/k8s.conf
sudo sysctl --system || true

# Containerd config reset (optional but nice to keep clean between rebuilds)
if [ -f /etc/containerd/config.toml ]; then
  echo "[INFO] Backing up containerd config to /root/config.toml.bak..."
  sudo mv /etc/containerd/config.toml /root/config.toml.bak.$(date +%s) || true
fi

echo "[INFO] Restarting containerd if installed..."
sudo systemctl daemon-reload || true
sudo systemctl restart containerd 2>/dev/null || true
sudo systemctl enable containerd 2>/dev/null || true

echo "[INFO] Cleaning apt cache..."
sudo apt-get clean
sudo apt-get autoclean
sudo apt-get autoremove -y

# Dangerous: Purging ALL "rc" packages (global system cleanup).
# This is not strictly related to Kubernetes and can be surprising.
# Uncomment only if you really want this behavior.
# echo "[INFO] Purging all rc-state packages..."
# sudo dpkg --purge $(COLUMNS=300 dpkg -l "*" | awk '/^rc/ {print $2}') 2>/dev/null || true

echo "[INFO] Node cleanup complete."
