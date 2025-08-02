# Puchi Gateway Setup Script
param(
    [switch]$BuildRunner,
    [switch]$StartOnly
)

Write-Host "🚀 Puchi Gateway Setup" -ForegroundColor Green

if ($BuildRunner -or -not $StartOnly) {
    Write-Host "📦 Building Go Plugin Runner..." -ForegroundColor Yellow
    
    # Build go-runner image
    docker build -f Dockerfile.go-runner -t go-runner:latest .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to build go-runner image" -ForegroundColor Red
        exit 1
    }
    
    # Create temporary container and copy binary
    Write-Host "📋 Extracting go-runner binary..." -ForegroundColor Yellow
    docker create --name temp-go-runner go-runner:latest
    docker cp temp-go-runner:/usr/local/bin/main ./go-runner
    docker rm temp-go-runner
    
    if (Test-Path "./go-runner") {
        Write-Host "✅ Go Plugin Runner binary created successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to extract go-runner binary" -ForegroundColor Red
        exit 1
    }
}

Write-Host "🚀 Starting Gateway services..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Gateway services started successfully" -ForegroundColor Green
    
    # Wait for services to be ready
    Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # Test APISIX
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:9180/apisix/admin/services" -Method GET -Headers @{"X-API-KEY"="edd1c9f034335f136f87ad84b625c8f1"} -TimeoutSec 5
        Write-Host "✅ APISIX is running" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  APISIX might still be starting up..." -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "🎉 Gateway is ready!" -ForegroundColor Green
    Write-Host "📊 Services:" -ForegroundColor Cyan
    Write-Host "   - APISIX API: http://localhost:9080" -ForegroundColor White
    Write-Host "   - APISIX Admin: http://localhost:9180" -ForegroundColor White
    Write-Host "   - Prometheus: http://localhost:9090" -ForegroundColor White
    Write-Host "   - Grafana: http://localhost:3000" -ForegroundColor White
    Write-Host "   - RabbitMQ: http://localhost:15672" -ForegroundColor White
    Write-Host ""
    Write-Host "🔧 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Start your microservices (auth-service, user-service)" -ForegroundColor White
    Write-Host "   2. Configure routes in APISIX Admin" -ForegroundColor White
    Write-Host "   3. Test with: curl http://localhost:9080/test-go-plugin" -ForegroundColor White
    
} else {
    Write-Host "❌ Failed to start gateway services" -ForegroundColor Red
    exit 1
} 