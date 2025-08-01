# APISIX Configuration Script
# Admin API endpoint
$APISIX_ADMIN = "http://localhost:9180/apisix/admin"
$ADMIN_KEY = "edd1c9f034335f136f87ad84b625c8f1"

# Headers for API calls
$headers = @{
    "X-API-KEY" = $ADMIN_KEY
    "Content-Type" = "application/json"
}

Write-Host "🚀 Setting up APISIX configuration..." -ForegroundColor Green

# 1. Create Upstreams
Write-Host "📡 Creating upstreams..." -ForegroundColor Yellow

# Auth App Upstream
$authAppUpstream = @{
    type = "roundrobin"
    nodes = @{
        "auth-app:8001" = 1
    }
    desc = "Auth service HTTP upstream"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$APISIX_ADMIN/upstreams/1" -Method PUT -Headers $headers -Body $authAppUpstream

# Auth gRPC Upstream  
$authGrpcUpstream = @{
    type = "roundrobin"
    nodes = @{
        "auth-app:9001" = 1
    }
    desc = "Auth service gRPC upstream"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$APISIX_ADMIN/upstreams/2" -Method PUT -Headers $headers -Body $authGrpcUpstream

# User App Upstream
$userAppUpstream = @{
    type = "roundrobin"
    nodes = @{
        "user-app:8002" = 1
    }
    desc = "User service HTTP upstream"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$APISIX_ADMIN/upstreams/3" -Method PUT -Headers $headers -Body $userAppUpstream

# User gRPC Upstream
$userGrpcUpstream = @{
    type = "roundrobin"
    nodes = @{
        "user-app:9002" = 1
    }
    desc = "User service gRPC upstream"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$APISIX_ADMIN/upstreams/4" -Method PUT -Headers $headers -Body $userGrpcUpstream

Write-Host "✅ Upstreams created successfully!" -ForegroundColor Green

# 2. Create Services
Write-Host "🔧 Creating services..." -ForegroundColor Yellow

# Auth HTTP Service
$authService = @{
    upstream_id = "1"
    plugins = @{
        "proxy-rewrite" = @{
            regex_uri = @("^/auth/(.*)", "/`$1")
        }
        cors = @{
            allow_origins = "*"
            allow_methods = "GET,POST,PUT,DELETE,OPTIONS"
            allow_headers = "*"
            expose_headers = "*"
            max_age = 5
            allow_credential = $false
        }
    }
    desc = "Auth service HTTP API"
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "$APISIX_ADMIN/services/1" -Method PUT -Headers $headers -Body $authService

# Auth gRPC Service
$authGrpcService = @{
    upstream_id = "2"
    plugins = @{
        "grpc-web" = @{}
        cors = @{
            allow_origins = "*"
            allow_methods = "GET,POST,OPTIONS"
            allow_headers = "*"
            expose_headers = "*"
            max_age = 5
            allow_credential = $false
        }
    }
    desc = "Auth service gRPC API"
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "$APISIX_ADMIN/services/2" -Method PUT -Headers $headers -Body $authGrpcService

# User HTTP Service
$userService = @{
    upstream_id = "3"
    plugins = @{
        "proxy-rewrite" = @{
            regex_uri = @("^/user/(.*)", "/`$1")
        }
        cors = @{
            allow_origins = "*"
            allow_methods = "GET,POST,PUT,DELETE,OPTIONS"
            allow_headers = "*"
            expose_headers = "*"
            max_age = 5
            allow_credential = $false
        }
    }
    desc = "User service HTTP API"
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "$APISIX_ADMIN/services/3" -Method PUT -Headers $headers -Body $userService

# User gRPC Service
$userGrpcService = @{
    upstream_id = "4"
    plugins = @{
        "grpc-web" = @{}
        cors = @{
            allow_origins = "*"
            allow_methods = "GET,POST,OPTIONS"
            allow_headers = "*"
            expose_headers = "*"
            max_age = 5
            allow_credential = $false
        }
    }
    desc = "User service gRPC API"
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "$APISIX_ADMIN/services/4" -Method PUT -Headers $headers -Body $userGrpcService

Write-Host "✅ Services created successfully!" -ForegroundColor Green

# 3. Create Routes
Write-Host "🛣️ Creating routes..." -ForegroundColor Yellow

# Auth HTTP Route
$authHttpRoute = @{
    uri = "/auth/*"
    service_id = "1"
    methods = @("GET", "POST", "PUT", "DELETE", "OPTIONS")
    desc = "Auth service HTTP route"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$APISIX_ADMIN/routes/1" -Method PUT -Headers $headers -Body $authHttpRoute

# Auth gRPC Route
$authGrpcRoute = @{
    uri = "/auth/grpc/*"
    service_id = "2"
    methods = @("GET", "POST", "OPTIONS")
    desc = "Auth service gRPC route"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$APISIX_ADMIN/routes/2" -Method PUT -Headers $headers -Body $authGrpcRoute

# User HTTP Route
$userHttpRoute = @{
    uri = "/user/*"
    service_id = "3"
    methods = @("GET", "POST", "PUT", "DELETE", "OPTIONS")
    desc = "User service HTTP route"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$APISIX_ADMIN/routes/3" -Method PUT -Headers $headers -Body $userHttpRoute

# User gRPC Route
$userGrpcRoute = @{
    uri = "/user/grpc/*"
    service_id = "4"
    methods = @("GET", "POST", "OPTIONS")
    desc = "User service gRPC route"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$APISIX_ADMIN/routes/4" -Method PUT -Headers $headers -Body $userGrpcRoute

Write-Host "✅ Routes created successfully!" -ForegroundColor Green

Write-Host "🎉 APISIX configuration completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Available endpoints:" -ForegroundColor Cyan
Write-Host "  • Auth HTTP API: http://localhost:9080/auth/*" -ForegroundColor White
Write-Host "  • Auth gRPC API: http://localhost:9080/auth/grpc/*" -ForegroundColor White
Write-Host "  • User HTTP API: http://localhost:9080/user/*" -ForegroundColor White
Write-Host "  • User gRPC API: http://localhost:9080/user/grpc/*" -ForegroundColor White
Write-Host ""
Write-Host "🔧 APISIX Admin API: http://localhost:9180" -ForegroundColor Cyan
Write-Host "📊 Prometheus Metrics: http://localhost:9091" -ForegroundColor Cyan 