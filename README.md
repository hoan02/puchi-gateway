# Puchi Gateway

Một API Gateway dựa trên Apache APISIX với monitoring và dashboard tích hợp.

## 🚀 Tính năng

- **API Gateway**: Apache APISIX làm gateway chính
- **Load Balancing**: Cân bằng tải giữa các upstream services
- **Monitoring**: Prometheus + Grafana để theo dõi hiệu suất
- **Dashboard UI**: Giao diện quản lý trực quan
- **Service Discovery**: Tích hợp với etcd

## 🏗️ Kiến trúc

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Client    │───▶│   APISIX    │───▶│   Web1/2    │
│             │    │  Gateway    │    │  Services   │
└─────────────┘    └─────────────┘    └─────────────┘
                          │
                    ┌─────────────┐
                    │    etcd     │
                    │  (Config)   │
                    └─────────────┘
                          │
              ┌─────────────────────┐
              │   Prometheus +      │
              │     Grafana         │
              │   (Monitoring)      │
              └─────────────────────┘
```

## 🛠️ Cài đặt và Chạy

### Yêu cầu

- Docker và Docker Compose
- Ports: 9080, 9180, 9090, 3000, 2379

### Khởi động

```bash
# Chạy toàn bộ stack
docker-compose up -d

# Hoặc chạy standalone mode
docker-compose -f docker-compose-standalone.yml up -d
```

## 📊 Dashboard và Monitoring

### APISIX Dashboard UI

- **URL**: http://127.0.0.1:9180/ui
- **Chức năng**: Quản lý routes, services, upstreams, plugins
- **Authentication**: Sử dụng admin key từ config

### Grafana Dashboard

- **URL**: http://127.0.0.1:3000
- **Chức năng**: Monitoring metrics, alerts, visualizations
- **Default credentials**: admin/admin

### Prometheus

- **URL**: http://127.0.0.1:9090
- **Chức năng**: Metrics collection và query

## 🔧 Cấu hình

### APISIX

- **Admin API**: http://127.0.0.1:9180/apisix/admin
- **Proxy**: http://127.0.0.1:9080
- **Config**: `apisix_conf/config.yaml`

### Upstream Services

- **Web1**: http://127.0.0.1:9081 (hello web1)
- **Web2**: http://127.0.0.1:9082 (hello web2)

### etcd

- **URL**: http://127.0.0.1:2379
- **Prefix**: `/apisix`

## 📁 Cấu trúc thư mục

```
puchi-gateway/
├── apisix_conf/          # APISIX configuration
├── etcd_conf/            # etcd configuration
├── grafana_conf/         # Grafana dashboards & config
├── prometheus_conf/      # Prometheus configuration
├── upstream/             # Upstream service configs
├── docker-compose.yml    # Main compose file
└── README.md            # This file
```

## 🔑 API Keys

- **Admin**: `edd1c9f034335f136f87ad84b625c8f1`
- **Viewer**: `4054f7cf07e344346cd3f287985e76a2`

## 📈 Monitoring Metrics

Dashboard cung cấp các metrics:

- Request rate, latency, error rate
- Upstream health status
- Plugin performance
- System resources

## 🚀 Quick Start

1. Clone repository
2. Chạy `docker-compose up -d`
3. Truy cập Dashboard UI: http://127.0.0.1:9180/ui
4. Truy cập Grafana: http://127.0.0.1:3000
5. Test API: http://127.0.0.1:9080

## 📝 License

Apache License 2.0
