# Web1

Next.js App Router frontend. It fetches hardcoded items from Api1 on the server.

| | |
| --- | --- |
| Image | `node:22-alpine` |
| Container port | `3000` |
| Public URL | http://localhost (through nginx) |
| Direct URL | http://localhost:3000 |

`API_URL` is the base URL Web1 uses to call Api1:

- Local Compose: `http://api1:8080`
- Swarm overlay: `http://api:8080`
- Local Next.js: `http://localhost:8080`

The three-host lab is [../swarm/README.md](../swarm/README.md).

## Run with Docker

Prefer Compose from the repo root so nginx and Api1 start together. To run Web1 alone you still need Api1 reachable:

```bash
docker build -t web1 .
docker run --rm -p 3000:3000 -e API_URL=http://host.docker.internal:8080 --name web1 web1
```
