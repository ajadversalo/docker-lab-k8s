# nginx (local Compose only)

Load balancer for `web1` and `web2` when you run `docker compose` on Windows.

The four-host lab uses apt nginx on vm4 instead. That config is `k8s/nginx.conf`.

```text
browser → nginx:80 → web1:3000 or web2:3000
```

Round-robin by default. If one web container is down, nginx marks it failed (`max_fails=1`) and sends the request to the other.

Hit a specific instance on its published port:

- http://localhost:3000 — web1 only
- http://localhost:3001 — web2 only
