# Puchi Gateway - Quick Start

## 🚀 Khởi chạy nhanh

```powershell
# Lần đầu
.\setup-gateway.ps1

# Lần sau (chỉ start services)
.\setup-gateway.ps1 -StartOnly
```

## 🔧 Khi sửa code Go Plugin Runner

```powershell
.\rebuild-runner.ps1
```

## 📊 Services URLs

- **APISIX API**: http://localhost:9080
- **APISIX Admin**: http://localhost:9180
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000
- **RabbitMQ**: http://localhost:15672

## 🧪 Test

```bash
# Test Go Plugin Runner
curl http://localhost:9080/test-go-plugin

# Test Auth Service (cần start auth-service trước)
curl http://localhost:9080/auth/

# Test User Service (cần start user-service trước)
curl http://localhost:9080/user/
```

## 📝 Routes cần cấu hình

### Auth Service

- `/auth/*` → host.docker.internal:8001

### User Service

- `/user/*` → host.docker.internal:8002

## ⚠️ Lưu ý

1. Start microservices trước khi test routes
2. Build lại Go Plugin Runner khi sửa code
3. APISIX sẽ restart tự động sau khi rebuild runner
