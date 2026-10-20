# Api1

ASP.NET Core 8 API that serves hardcoded Docker-lab items. No database.

| | |
| --- | --- |
| Image | `mcr.microsoft.com/dotnet/aspnet:8.0` |
| Container port | `8080` |
| Host URL | http://localhost:8080 |

## Endpoints

- `GET /health` — liveness check
- `GET /api/items` — list of items
- `GET /api/items/{id}` — one item

## Run with Docker

```bash
docker build -t api1 .
docker run --rm -p 8080:8080 --name api1 api1
```

Then:

```bash
curl http://localhost:8080/api/items
```

From a web container on the Compose network:

- Web1 → `http://api1:8080`
- Web2 → `http://api2:8080`

Set `INSTANCE` so `/api/items` reports which container answered (`api1` or `api2`). Swarm sets this from the task slot and node hostname.

The three-host lab is [../swarm/README.md](../swarm/README.md).
