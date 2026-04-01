<#
.SYNOPSIS
    RAGent 一键公网部署脚本

.DESCRIPTION
    构建前端 → 启动 Docker Compose → 启动 Cloudflare Tunnel
    执行前请确保:
    1. Docker Desktop 已启动
    2. 已将 .env.example 复制为 .env 并填写 API Key
    3. 已安装 cloudflared (winget install Cloudflare.cloudflared)
#>

param(
    [switch]$SkipFrontend,
    [switch]$SkipBuild,
    [switch]$TunnelOnly
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   RAGent Public Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ---- Pre-checks ----
Write-Host "[1/5] Pre-flight checks..." -ForegroundColor Yellow

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker not found. Please install Docker Desktop." -ForegroundColor Red
    exit 1
}
$dockerStatus = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker Desktop is not running. Please start it first." -ForegroundColor Red
    exit 1
}
Write-Host "  Docker Desktop ............. OK" -ForegroundColor Green

# Check .env
$envFile = Join-Path $ProjectRoot ".env"
if (-not (Test-Path $envFile)) {
    Write-Host "  .env file not found. Creating from template..." -ForegroundColor Yellow
    Copy-Item (Join-Path $ProjectRoot ".env.example") $envFile
    Write-Host "  IMPORTANT: Please edit .env and fill in your API keys, then re-run this script." -ForegroundColor Red
    notepad $envFile
    exit 1
}
Write-Host "  .env file .................. OK" -ForegroundColor Green

# Check cloudflared
if (-not (Get-Command cloudflared -ErrorAction SilentlyContinue)) {
    Write-Host "  cloudflared not found. Installing via winget..." -ForegroundColor Yellow
    winget install Cloudflare.cloudflared --accept-source-agreements --accept-package-agreements
    Write-Host "  Please restart PowerShell and re-run this script." -ForegroundColor Yellow
    exit 1
}
Write-Host "  cloudflared ................ OK" -ForegroundColor Green

if ($TunnelOnly) {
    Write-Host ""
    Write-Host "[TUNNEL] Starting Cloudflare Tunnel..." -ForegroundColor Cyan
    Write-Host "  Press Ctrl+C to stop the tunnel." -ForegroundColor Gray
    cloudflared tunnel --url http://localhost:80
    exit 0
}

# ---- Build Frontend ----
if (-not $SkipFrontend) {
    Write-Host ""
    Write-Host "[2/5] Building frontend..." -ForegroundColor Yellow

    Push-Location (Join-Path $ProjectRoot "frontend")

    if (-not (Test-Path "node_modules")) {
        Write-Host "  Installing npm dependencies..."
        npm install
    }

    Write-Host "  Running npm build..."
    npm run build

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Frontend build failed!" -ForegroundColor Red
        Pop-Location
        exit 1
    }

    Pop-Location
    Write-Host "  Frontend build ............. OK" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[2/5] Skipping frontend build (--SkipFrontend)" -ForegroundColor Gray
}

# ---- Docker Compose ----
if (-not $SkipBuild) {
    Write-Host ""
    Write-Host "[3/5] Building and starting Docker services..." -ForegroundColor Yellow

    Push-Location $ProjectRoot
    docker compose up -d --build
    Pop-Location

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Docker Compose failed!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "[3/5] Starting Docker services (no rebuild)..." -ForegroundColor Yellow
    Push-Location $ProjectRoot
    docker compose up -d
    Pop-Location
}

# ---- Health check ----
Write-Host ""
Write-Host "[4/5] Waiting for services to be ready..." -ForegroundColor Yellow

$maxRetries = 30
$retryCount = 0
$ready = $false

while (-not $ready -and $retryCount -lt $maxRetries) {
    Start-Sleep -Seconds 5
    $retryCount++
    Write-Host "  Checking... (attempt $retryCount/$maxRetries)" -ForegroundColor Gray

    try {
        $response = Invoke-WebRequest -Uri "http://localhost:80" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $ready = $true
        }
    } catch {
        # Not ready yet
    }
}

if ($ready) {
    Write-Host "  All services ............... OK" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Services may not be fully ready. Check 'docker compose logs'" -ForegroundColor Yellow
}

# ---- Show service status ----
Write-Host ""
Push-Location $ProjectRoot
docker compose ps
Pop-Location

# ---- Cloudflare Tunnel ----
Write-Host ""
Write-Host "[5/5] Starting Cloudflare Tunnel..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Your RAGent will be publicly accessible at the URL shown below." -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop the tunnel (Docker services will keep running)." -ForegroundColor Gray
Write-Host ""

cloudflared tunnel --url http://localhost:80
