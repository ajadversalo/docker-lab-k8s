# Four Linux hosts, nginx, and Kubernetes (k3s)

Swarm in `C:\repos\docker-lab` stays as it is. This lab uses different VM names, IPs, and Windows ports so **both can run at once**.

```text
[ Windows ]
   Swarm (unchanged): localhost :80 / :8080 → vm1
   K8s:               localhost :90 / :8090 → vm4
            |
            v
         vm4  nginx          ← outside the cluster (apt)
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

vm4 already has nginx. You install k3s, join the workers, cordon vm7, then apply `k8s/lab.yml`.

---

## What each machine does

| Host | IP | Role |
| --- | --- | --- |
| vm4 | 172.30.0.14 | nginx only. Does not join Kubernetes. Upstream is vm5, vm6, **and vm7**. |
| vm5 | 172.30.0.15 | Control plane (`k3s` server). Also runs pods. |
| vm6 | 172.30.0.16 | Worker (`k3s` agent). Runs pods. |
| vm7 | 172.30.0.17 | Hot spare worker (`k3s` agent). Joined and empty until a node dies. |

---

## Ports

| Host | SSH (PuTTY) | Windows → host :80 | Windows → host :8080 |
| --- | --- | --- | --- |
| vm4 | 2225 | http://localhost:90 | http://localhost:8090 |
| vm5 | 2226 | http://localhost:92 | http://localhost:8092 |
| vm6 | 2227 | http://localhost:91 | http://localhost:8091 |
| vm7 | 2228 | http://localhost:93 | http://localhost:8093 |

`localhost:90` is **always vm4**. Direct ports 91/92/93 skip nginx and hit that node.

`docker stop vm6` is like powering a VM off. `docker compose down` is like deleting the VMs. Named volumes keep k3s data unless you add `-v`.

---

## 0. Start the boxes (Windows)

Docker Desktop must be running. Swarm vm1–vm3 can stay up.

```powershell
cd C:\repos\docker-lab-k8s
.\k8s\up.ps1
```

Docker Desktop shows project `docker-lab-k8s` with `vm4`, `vm5`, `vm6`, `vm7`.

vm4 nginx is already running. **Current baseline:** Docker Engine plus one `web` and one `api` container on vm5, vm6, and vm7. http://localhost:90 and http://localhost:8090/health should be HTTP 200.

k3s is not installed yet. Before you install it, stop the Docker apps so ports 80 and 8080 are free:

```bash
# on each of vm5, vm6, vm7
docker rm -f web api
```

Images in use: `ghcr.io/ajadversalo/docker-lab/web:latest` and `ghcr.io/ajadversalo/docker-lab/api:latest` (both on GHCR). Docker storage on these VMs is `vfs` because compose does not mount `/var/lib/docker`.

---

## 1. PuTTY into each host

User `lab`, password `lab`.

| Host | PuTTY |
| --- | --- |
| vm4 | `127.0.0.1` port **2225** |
| vm5 | `127.0.0.1` port **2226** |
| vm6 | `127.0.0.1` port **2227** |
| vm7 | `127.0.0.1` port **2228** |

Or from PowerShell:

```powershell
ssh -p 2225 lab@127.0.0.1
ssh -p 2226 lab@127.0.0.1
ssh -p 2227 lab@127.0.0.1
ssh -p 2228 lab@127.0.0.1
```

On the box, `hostname` prints `vm4`, `vm5`, `vm6`, or `vm7`. **Do not join vm4.**

---

## 2. Install k3s on vm5 (server)

On **vm5**:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --node-ip 172.30.0.15 --tls-san 172.30.0.15 --tls-san vm5" sh -
sudo k3s kubectl get nodes
```

You should see `vm5` Ready. Traefik is off; vm4 nginx is the door.

Copy the join token:

```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

---

## 3. Join vm6 and vm7 (agents)

On **vm6**, paste the token in place of `TOKEN`:

```bash
curl -sfL https://get.k3s.io | K3S_URL=https://172.30.0.15:6443 K3S_TOKEN=TOKEN INSTALL_K3S_EXEC="--node-ip 172.30.0.16" sh -
```

On **vm7**, same command with `.17`:

```bash
curl -sfL https://get.k3s.io | K3S_URL=https://172.30.0.15:6443 K3S_TOKEN=TOKEN INSTALL_K3S_EXEC="--node-ip 172.30.0.17" sh -
```

On **vm5**:

```bash
sudo k3s kubectl get nodes -o wide
```

You should see vm5, vm6, and vm7 Ready.

---

## 4. Cordon the hot spare (vm7)

vm7 is joined so it can take pods when a busy node dies. Keep it empty until then.

On **vm5**:

```bash
sudo k3s kubectl cordon vm7
sudo k3s kubectl get nodes
```

vm7 should show `Ready,SchedulingDisabled`.

---

## 5. Put the manifests on vm5

From **PowerShell on Windows**:

```powershell
docker cp C:\repos\docker-lab-k8s\k8s\lab.yml vm5:/home/lab/lab.yml
docker exec vm5 sudo chown lab:lab /home/lab/lab.yml
```

vm5 `/tmp` is tmpfs. Copy to `/home/lab`, not `/tmp`.

---

## 6. Images on the cluster

Pods pull `ghcr.io/ajadversalo/docker-lab/web:latest` and `ghcr.io/ajadversalo/docker-lab/api:latest`. Both tags exist on GHCR when this lab starts. k3s pulls them into containerd; you do not `ctr import`.

If a pull is `denied`, the package is still private. Make it public or create a pull secret on **vm5**:

```bash
sudo k3s kubectl create secret docker-registry ghcr \
  --docker-server=ghcr.io \
  --docker-username=ajadversalo \
  --docker-password=YOUR_PAT
```

Then add to both Deployments in `lab.yml` under `spec.template.spec`:

```yaml
imagePullSecrets:
  - name: ghcr
```

---

## 7. Apply the app (vm5)

On **vm5**:

```bash
sudo k3s kubectl apply -f /home/lab/lab.yml
sudo k3s kubectl get deploy
sudo k3s kubectl get pods -o wide
sudo k3s kubectl get svc
```

Wait until both Deployments are 2/2. `-o wide` should show one web and one api on **vm5**, one of each on **vm6**, and **none on vm7**.

`hostPort` publishes web on node `:80` and api on node `:8080`. nginx on vm4 already lists all three node IPs.

Web pods call `http://api:8080` (ClusterIP Service). That name is cluster DNS, not nginx.

From Windows you can poke a busy node directly:

```powershell
curl.exe http://localhost:92/health
curl.exe http://localhost:91/health
```

Those hit vm5:80 and vm6:80. vm7:93 should fail until a pod lands there.

---

## 8. Verify through nginx (Windows)

```powershell
curl.exe http://localhost:90/health
curl.exe http://localhost:8090/health
curl.exe http://localhost:8090/api/items
```

Open http://localhost:90 in a browser. You should see the Web1 page. Refresh a few times; nginx `least_conn` picks vm5 or vm6.

| URL | What answers |
| --- | --- |
| http://localhost:90 | nginx on vm4 → a web pod on vm5 or vm6 |
| http://localhost:8090/health | nginx on vm4 → an api pod |
| http://localhost:92 | vm5 directly (hostPort) |
| http://localhost:91 | vm6 directly (hostPort) |
| http://localhost:93 | vm7 (empty until failover) |

API paths are `/health` and `/api/items`.

---

## 9. Failover (vm6 off, localhost:90 still works)

From **Windows**:

```powershell
docker stop vm6
curl.exe http://localhost:90/health
```

nginx marks vm6 failed and sends traffic to vm5. The page at http://localhost:90 should still load. The extra replica stays Pending until a schedulable node exists.

Bring the spare in, still on **vm5**:

```bash
sudo k3s kubectl uncordon vm7
sudo k3s kubectl get pods -o wide
```

The missing pair should land on vm7. http://localhost:93 should start answering. nginx already has `172.30.0.17` in the upstream.

Bring vm6 back:

```powershell
docker start vm6
```

Wait for k3s on vm6. Cordon vm7 again if you want it empty:

```bash
sudo k3s kubectl cordon vm7
```

---

## Stop the boxes (Windows)

```powershell
.\k8s\down.ps1
```

That removes `vm4`/`vm5`/`vm6`/`vm7`. Swarm is untouched. k3s state lives in named volumes, so the next `.\k8s\up.ps1` can come back with the cluster already installed.

Wipe k3s data:

```powershell
docker compose -f docker-compose.k8s.yml down -v
```

---

## Everyday commands on the server (vm5)

```bash
sudo k3s kubectl get nodes
sudo k3s kubectl get pods -o wide
sudo k3s kubectl get deploy,svc
sudo k3s kubectl logs -l app=web --tail=50
sudo k3s kubectl describe pod -l app=api
sudo k3s kubectl delete -f /home/lab/lab.yml
```

---

## If something fails

| Symptom | What to check |
| --- | --- |
| `k3s` not found | Step 2 / 3 on that host |
| vm7 has pods too early | Step 4 — `kubectl cordon vm7` |
| pods ImagePullBackOff | GHCR package still private — step 6 |
| localhost:90 502 | no pods yet, or hostPort not bound, or both busy nodes down |
| connection refused on :90 | nginx on vm4 not running — `sudo systemctl status nginx` |
| `docker cp` to `/tmp` missing | `/tmp` is tmpfs; copy to `/home/lab` |
| agent cannot join | token, `https://172.30.0.15:6443`, and `ping 172.30.0.15` from the agent |
| Port 90 already allocated | another process on Windows; this lab does not use port 80 |

Swarm lesson: `C:\repos\docker-lab\swarm\README.md`.
