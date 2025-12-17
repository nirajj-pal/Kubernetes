#!/usr/bin/env bash
set -euo pipefail


if [ "$EUID" -ne 0 ]; then
echo "Run as root"
exit 1
fi


if [ "$#" -lt 1 ]; then
echo "Usage: $0 '<full-worker-join-command>'"
exit 1
fi


JOIN_CMD="$1"


bash -c "$JOIN_CMD"


# show node status from worker (kubectl likely not configured here)
echo "Worker join executed. Check nodes from master01 or bastion (after copying kubeconfig)."
