# GitHub Actions in this lab

Two workflows. Read them in this order.

| File | What it teaches | When it runs |
| --- | --- | --- |
| [workflows/ci.yml](workflows/ci.yml) | jobs, steps, setup actions, parallel work, concurrency | every push / PR |
| [workflows/images.yml](workflows/images.yml) | matrix, GHCR login, build vs push, path filters | app or Dockerfile changes on main / PR |

## How to see a run

1. Push these files to GitHub (or open a PR).
2. Open **Actions** on the repo.
3. Click **ci**, then a run, then a job. Each step is a fold-out log.

To run without a code change: **Actions → ci → Run workflow**.

## What each file is doing

`ci.yml` compiles Api1 (dotnet 8) and Web1 (Next.js 15) and schema-checks `k8s/lab.yml`. It never talks to vm4–vm7. Failures here mean the source does not build or the manifest is invalid YAML/schema.

`images.yml` builds the same Dockerfiles you use on the VMs. On a pull request it only builds. On `main` it pushes:

- `ghcr.io/ajadversalo/docker-lab-k8s/api:latest` (and `sha-<short>`)
- `ghcr.io/ajadversalo/docker-lab-k8s/web:latest` (and `sha-<short>`)

The first package may be private. In the GHCR package settings, set visibility to public if k3s should pull without a secret.

`k8s/lab.yml` still uses `ghcr.io/ajadversalo/docker-lab/web:latest` and `.../api:latest`. Change those image lines when you want this repo's builds to land on the cluster.

## Things to try next

After you have watched a green `ci` run:

1. Break `Api1/Program.cs` on a branch, open a PR, watch `build api` go red.
2. Add a path filter on the `k8s` job so it only runs when `k8s/**` changes (`dorny/paths-filter`).
3. Add a job that `docker compose -f docker-compose.yml config` so Compose YAML is checked too.
4. Point `k8s/lab.yml` at `ghcr.io/ajadversalo/docker-lab-k8s/api:sha-...` and apply on vm5.
