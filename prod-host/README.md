# Empty Linux host image

Ubuntu 24.04 with SSH and systemd. **k3s is not installed.** You log in and install it on vm5–vm7.

The four-host Kubernetes lab is the main path: [../k8s/README.md](../k8s/README.md).

vm4 uses [../k8s/door.Dockerfile](../k8s/door.Dockerfile) (this image plus apt nginx).

## What this image contains

SSH, git, curl, sudo, systemd as PID 1. Login `lab` / `lab` (local training only).
