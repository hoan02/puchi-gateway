# Rebuild Go Plugin Runner Script
Write-Host "🔄 Rebuilding Go Plugin Runner..." -ForegroundColor Yellow

# Build go-runner image
Write-Host "📦 Building Docker image..." -ForegroundColor Cyan
docker build -f Dockerfile.go-runner -t go-runner:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build go-runner image" -ForegroundColor Red
    exit 1
}

# Create temporary container and copy binary
Write-Host "📋 Extracting binary..." -ForegroundColor Cyan
docker create --name temp-go-runner go-runner:latest
docker cp temp-go-runner:/usr/local/bin/main ./go-runner
docker rm temp-go-runner

if (Test-Path "./go-runner") {
    Write-Host "✅ Go Plugin Runner binary updated successfully" -ForegroundColor Green
    
    # Restart APISIX to pick up new binary
    Write-Host "🔄 Restarting APISIX..." -ForegroundColor Yellow
    docker-compose restart apisix
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ APISIX restarted successfully" -ForegroundColor Green
        Write-Host "⏳ Waiting for APISIX to be ready..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        
        # Test the updated runner
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:9080/test-go-plugin" -Method GET -TimeoutSec 5
            Write-Host "✅ Go Plugin Runner is working correctly" -ForegroundColor Green
            Write-Host "📄 Response: $($response.Content)" -ForegroundColor White
        } catch {
            Write-Host "⚠️  Test route might not be configured. You can test manually:" -ForegroundColor Yellow
            Write-Host "   curl http://localhost:9080/test-go-plugin" -ForegroundColor White
        }
    } else {
        Write-Host "❌ Failed to restart APISIX" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ Failed to extract go-runner binary" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 Go Plugin Runner rebuild completed!" -ForegroundColor Green 