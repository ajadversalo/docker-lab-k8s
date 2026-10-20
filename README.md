# Docker lab — Kubernetes

Sibling of `C:\repos\docker-lab` (Swarm vm1–vm3). This folder is the k3s lab. **Both can run at once.**

```text
[ Windows ]
   Swarm (unchanged): localhost :80 / :8080 → vm1
   K8s:               localhost :90 / :8090 → vm4
            |
            v
         vm4  nginx          ← outside the cluster (apt, already installed)
         172.30.0.14
            /     |      \
           v      v       v
         vm5    vm6      vm7
      .15      .16      .17
      k3s      k3s      k3s
      server   agent    agent (hot spare)
      pods     pods     empty until a node dies
            \     |      /
         cluster network
         2 web pods + 2 api pods  (one pair per busy node)
         Service: web, Service: api
         web → http://api:8080
```

Full walkthrough: **[k8s/README.md](k8s/README.md)**

```powershell
.\k8s\up.ps1
```

| Host | IP | Role | PuTTY |
| --- | --- | --- | --- |
| vm4 | 172.30.0.14 | nginx (incoming), not in the cluster | `127.0.0.1` port **2225** |
| vm5 | 172.30.0.15 | k3s server, runs pods | `127.0.0.1` port **2226** |
| vm6 | 172.30.0.16 | k3s agent, runs pods | `127.0.0.1` port **2227** |
| vm7 | 172.30.0.17 | k3s agent, hot spare | `127.0.0.1` port **2228** |

http://localhost:90 always hits **vm4**. **Now:** Docker `web` + `api` on vm5–vm7, so `:90` / `:8090` return 200. k3s is later; stop those containers first. If vm6 is off, nginx still reaches vm5 (and vm7 after you uncordon it).

Do not run local Compose in this folder at the same time as Swarm vm1 (`C:\repos\docker-lab`) — that Compose file still binds 80 and 8080.

---

## What lives in this folder

| Path | What it is |
| --- | --- |
| `docker-compose.k8s.yml` | Starts hosts `vm4` / `vm5` / `vm6` / `vm7` on `172.30.0.0/24` |
| `prod-host/` | Ubuntu image: SSH + systemd. **No k3s in the image.** |
| `k8s/door.Dockerfile` | vm4 image: same Ubuntu **plus apt nginx** |
| `k8s/` | Lesson, `lab.yml`, nginx config, start/stop scripts |
| `Api1/` | Static JSON API (same as the Swarm lab) |
| `Web1/` | Next.js page that reads the API |
| `nginx/` | nginx image for **local Compose only** |
| `docker-compose.yml` | Local Compose on Windows (optional; collides with Swarm ports) |

Web2 is the same `Web1` image with different env vars. There is no `Web2/` folder.
