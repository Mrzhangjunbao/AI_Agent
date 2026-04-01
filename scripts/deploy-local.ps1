param(
  [switch]$StartBackend,
  [switch]$BuildFrontend
)

$ErrorActionPreference = "Stop"

Write-Host "[1/6] 检查 Docker..."
docker --version | Out-Null

Write-Host "[2/6] 启动 PostgreSQL + Redis..."
docker compose -f resources/docker/app-stack.compose.yaml up -d

Write-Host "[3/6] 启动 RocketMQ..."
docker compose -f resources/docker/rocketmq-stack-5.2.0.compose.yaml up -d

Write-Host "[4/6] 启动 RustFS/Milvus 依赖栈..."
docker compose -f resources/docker/milvus-stack-2.6.6.compose.yaml up -d

if (-not (Test-Path "bootstrap/src/main/resources/application-local.yaml")) {
  Write-Host "[5/6] 生成本地私有配置模板文件..."
  Copy-Item "bootstrap/src/main/resources/application-local.example.yaml" "bootstrap/src/main/resources/application-local.yaml"
  Write-Host "请先填写 application-local.yaml 中的 API Key，再重启后端。"
}

if ($StartBackend) {
  Write-Host "[6/6] 启动后端（local profile）..."
  ./mvnw -pl bootstrap spring-boot:run "-Dspring-boot.run.profiles=local"
} else {
  Write-Host "[6/6] 基础依赖启动完成。"
  Write-Host "后端启动命令: ./mvnw -pl bootstrap spring-boot:run \"-Dspring-boot.run.profiles=local\""
}

if ($BuildFrontend) {
  Write-Host "构建前端..."
  Push-Location frontend
  npm install
  npm run build
  Pop-Location
}
