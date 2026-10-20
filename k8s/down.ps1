$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

Write-Host "Stopping Kubernetes lab hosts vm4, vm5, vm6, and vm7..."
Write-Host "Swarm vm1–vm3 are not touched."
docker compose -f docker-compose.k8s.yml down
Write-Host "Add -v to also wipe k3s data: docker compose -f docker-compose.k8s.yml down -v"
