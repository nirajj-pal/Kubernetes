#!/bin/bash
set -euo pipefail

echo "CLEANUP: hostname=$(hostname -f) - kubeadm reset and remove leftovers"
read -p "Type 'yes' to proceed: " yn
if [[ "$yn" != "yes" ]]; then
  echo "Aborted."
  exit 1
fi

systemctl stop kubelet || true
kubeadm reset -f || true

# Remove CNI/net artifacts
ip link delete cni0 2>/dev/null || true
ip link delete flannel.1 2>/dev/null || true
ip link delete weave 2>/dev/null || true

# Remove k8s dirs
rm -rf /etc/kubernetes /var/lib/etcd /var/lib/kubelet /var/lib/cni /opt/cni /

# Remove containerd state (keeps containerd package)
systemctl stop containerd || true
rm -rf /var/lib/containerd/* || true
systemctl restart containerd || true

# Flush iptables (careful on production - we assume isolated nodes)
iptables -F || true
iptables -t nat -F || true
iptables -t mangle -F || true
iptables -X || true

echo "CLEANUP complete on $(hostname -f). Reboot recommended but optional."
