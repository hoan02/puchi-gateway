# Puchi Gateway

Gateway service sử dụng Apache APISIX để quản lý traffic đến các microservices của Puchi.

## Cấu trúc Services

Gateway chỉ chứa các services cần thiết cho việc routing và monitoring:

- **apisix**: API Gateway chính với Go Plugin Runner
- **etcd**: Configuration store
- **rabbitmq**: Shared message broker
- **prometheus**: Monitoring metrics
- **grafana**: Dashboard monitoring

Các microservices chạy độc lập:

- **puchi-auth-service**: Service xác thực (port 8001)
- **puchi-user-service**: Service quản lý user (port 8002)

## Cấu hình Routing

### Auth Service Routes:

- `/auth/*` → host.docker.internal:8001 (HTTP API)

### User Service Routes:

- `/user/*` → host.docker.internal:8002 (HTTP API)

## Ports

### Gateway Services:

- **APISIX**: 9080 (API), 9180 (Admin), 9091 (Prometheus), 9443 (HTTPS)
- **etcd**: 2379
- **RabbitMQ**: 5672 (AMQP), 15672 (Management)
- **Prometheus**: 9090
- **Grafana**: 3000

### External Services (chạy độc lập):

- **Auth Service**: 8001 (HTTP)
- **User Service**: 8002 (HTTP)

## Khởi chạy

### Cách 1: Sử dụng script tự động (Khuyến nghị)

```powershell
# Lần đầu hoặc khi sửa code Go Plugin Runner
.\setup-gateway.ps1

# Chỉ start services (không build lại)
.\setup-gateway.ps1 -StartOnly
```

### Cách 2: Thủ công

#### 1. Build Go Plugin Runner (chỉ cần làm 1 lần hoặc khi sửa code):

```bash
cd puchi-gateway
docker build -f Dockerfile.go-runner -t go-runner:latest .
docker create --name temp-go-runner go-runner:latest
docker cp temp-go-runner:/usr/local/bin/main ./go-runner
docker rm temp-go-runner
```

#### 2. Khởi chạy Gateway:

```bash
docker-compose up -d
```

### 3. Khởi chạy các microservices độc lập:

```bash
# Auth Service
cd ../puchi-auth-service
docker-compose up -d

# User Service
cd ../puchi-user-service
docker-compose up -d
```

### 4. Kiểm tra kết nối:

```bash
# Test Auth Service
curl http://localhost:9080/auth/

# Test User Service
curl http://localhost:9080/user/

# Test Go Plugin Runner
curl http://localhost:9080/test-go-plugin
```

## Go Plugin Runner

Gateway được cấu hình với Apache APISIX Go Plugin Runner để hỗ trợ viết plugin tùy chỉnh bằng Go.

### Khi sửa code Go Plugin Runner:

#### Cách 1: Sử dụng script tự động

```powershell
.\rebuild-runner.ps1
```

#### Cách 2: Thủ công

1. **Build lại binary:**

   ```bash
   docker build -f Dockerfile.go-runner -t go-runner:latest .
   docker create --name temp-go-runner go-runner:latest
   docker cp temp-go-runner:/usr/local/bin/main ./go-runner
   docker rm temp-go-runner
   ```

2. **Restart APISIX:**
   ```bash
   docker-compose restart apisix
   ```

### Test Go Plugin:

```bash
# Tạo test route
curl -X PUT "http://localhost:9180/apisix/admin/routes/1" \
  -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" \
  -H "Content-Type: application/json" \
  -d @test-route.json

# Test route
curl http://localhost:9080/test-go-plugin
```

## Monitoring

- **APISIX Dashboard**: http://localhost:9180
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000
- **RabbitMQ Management**: http://localhost:15672

## Cấu hình Environment Variables

Các biến môi trường có thể được cấu hình trong file `.env`:

```env
APISIX_IMAGE_TAG=3.13.0-debian
```

## Kiến trúc

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client        │───▶│   APISIX        │───▶│   Auth Service  │
│                 │    │   Gateway       │    │   (Port 8001)   │
└─────────────────┘    │   + Go Runner   │    └─────────────────┘
                       └─────────────────┘
                              │
                       ┌─────────────────┐    ┌─────────────────┐
                       │      etcd       │    │   User Service  │
                       │   (Config)      │    │   (Port 8002)   │
                       └─────────────────┘    └─────────────────┘
                              │
                ┌─────────────────────────────┐
                │   Prometheus + Grafana      │
                │   (Monitoring)              │
                └─────────────────────────────┘
```

## Lưu ý quan trọng

- Gateway sử dụng `host.docker.internal` để kết nối đến các services chạy trên host
- Các microservices phải được khởi chạy trước khi gateway có thể route traffic
- Đảm bảo ports 8001, 8002 không bị conflict với services khác
- Go Plugin Runner binary phải được build lại khi có thay đổi code
- APISIX cần restart sau khi cập nhật Go Plugin Runner binary
