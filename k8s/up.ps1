$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

Write-Host "Starting Kubernetes lab hosts vm4, vm5, vm6, vm7..."
Write-Host "Swarm vm1–vm3 are left running if they are already up."

# Door image FROM docker-lab-k8s-linux — build an app VM first.
docker compose -f docker-compose.k8s.yml build vm5
if ($LASTEXITCODE -ne 0) { throw "Failed to build docker-lab-k8s-linux" }

docker compose -f docker-compose.k8s.yml up -d --build
if ($LASTEXITCODE -ne 0) { throw "Failed to start docker-lab-k8s hosts" }

function Wait-Ssh([string]$Name) {
  Write-Host "Waiting for SSH on $Name..."
  for ($i = 0; $i -lt 60; $i++) {
    docker exec $Name systemctl is-active ssh 1>$null 2>$null
    if ($LASTEXITCODE -eq 0) {
      Write-Host "$Name is ready."
      return
    }
    Start-Sleep -Seconds 2
  }
  throw "SSH on $Name did not start in time."
}

Wait-Ssh vm4
Wait-Ssh vm5
Wait-Ssh vm6
Wait-Ssh vm7

Write-Host ""
Write-Host "Hosts are up. vm4 already has nginx. k3s is not installed yet."
Write-Host "  PuTTY  vm4  127.0.0.1 port 2225  lab / lab   (nginx door)"
Write-Host "  PuTTY  vm5  127.0.0.1 port 2226  lab / lab   (k3s server)"
Write-Host "  PuTTY  vm6  127.0.0.1 port 2227  lab / lab   (k3s agent)"
Write-Host "  PuTTY  vm7  127.0.0.1 port 2228  lab / lab   (hot spare)"
Write-Host ""
Write-Host "Windows: http://localhost:90  and  http://localhost:8090  (502 until k3s publishes pods)"
Write-Host "Follow k8s/README.md"
