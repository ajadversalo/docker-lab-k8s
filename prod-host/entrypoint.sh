#!/bin/bash
set -euo pipefail

ssh-keygen -A

HOST="$(hostname)"
case "${HOST}" in
  vm4)
    NEXT="nginx is already installed. Do not install k3s. Do not join the cluster."
    ;;
  vm5)
    NEXT="Install k3s server (control plane). This node also runs pods."
    ;;
  vm6)
    NEXT="Install k3s agent and join vm5. This node runs pods."
    ;;
  vm7)
    NEXT="Install k3s agent and join vm5, then cordon this node. Hot spare until a node dies."
    ;;
  *)
    NEXT="See k8s/README.md in the docker-lab-k8s repo."
    ;;
esac

cat >/etc/motd <<EOF

============================================================
  Linux host  (hostname: ${HOST})
  PuTTY/SSH the same way you would at work.

  Login:  lab / lab   (local training only)

  ${NEXT}

  Guide: k8s/README.md in the docker-lab-k8s repo
============================================================
EOF

exec /lib/systemd/systemd
