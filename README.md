# Puchi Gateway

Gateway service sử dụng Apache APISIX để quản lý traffic đến các microservices của Puchi.

## Cấu trúc Services

Gateway chỉ chứa các services cần thiết cho việc routing và monitoring:

- **apisix**: API Gateway chính
- **etcd**: Configuration store
- **rabbitmq**: Shared message broker
- **prometheus**: Monitoring metrics
- **grafana**: Dashboard monitoring

Các microservices chạy độc lập:

- **puchi-auth-service**: Service xác thực (port 8001, 9001)
- **puchi-user-service**: Service quản lý user (port 8002, 9002)

## Cấu hình Routing

### Auth Service Routes:

- `/auth/*` → host.docker.internal:8001 (HTTP API)
- `/auth/grpc/*` → host.docker.internal:9001 (gRPC)

### User Service Routes:

- `/user/*` → host.docker.internal:8002 (HTTP API)
- `/user/grpc/*` → host.docker.internal:9002 (gRPC)

## Ports

### Gateway Services:

- **APISIX**: 9080 (API), 9180 (Admin), 9091 (Prometheus), 9443 (HTTPS)
- **etcd**: 2379
- **RabbitMQ**: 5672 (AMQP), 15672 (Management)
- **Prometheus**: 9090
- **Grafana**: 3000

### External Services (chạy độc lập):

- **Auth Service**: 8001 (HTTP), 9001 (gRPC)
- **User Service**: 8002 (HTTP), 9002 (gRPC)

## Khởi chạy

### 1. Khởi chạy Gateway:

```bash
cd puchi-gateway
docker-compose up -d
```

### 2. Khởi chạy các microservices độc lập:

```bash
# Auth Service
cd ../puchi-auth-service
docker-compose up -d

# User Service
cd ../puchi-user-service
docker-compose up -d
```

### 3. Kiểm tra kết nối:

```bash
# Test Auth Service
curl http://localhost:9080/auth/

# Test User Service
curl http://localhost:9080/user/
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
└─────────────────┘    └─────────────────┘    └─────────────────┘
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
- Đảm bảo ports 8001, 9001, 8002, 9002 không bị conflict với services khác
