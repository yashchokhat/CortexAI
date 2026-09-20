# CortexAI Backend

A high-performance Go backend service for the CortexAI Edge AI ecosystem, built using the [Gin](https://github.com/gin-gonic/gin) framework.

## Features

- **Blazing Fast**: Built on Gin with minimal latency and high throughput.
- **CORS Enabled**: Configured to work seamlessly with Flutter Web (`localhost`), Android Emulator (`10.0.2.2`), and mobile/desktop clients.
- **Edge AI Ready**: REST endpoints to manage edge devices (ESP32-S3, ESP32-P4) and coordinate edge intelligence inference tasks.

## Quick Start

### 1. Run Locally

```bash
cd cortexai_backend
go run main.go
```

The server will start on `http://localhost:8000`. You can customize the port via the `PORT` environment variable:

```bash
PORT=9000 go run main.go
```

### 2. Run Tests

```bash
go test -v ./...
```

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/` | API Root / Welcome |
| `GET` | `/health` | Health check & uptime |
| `GET` | `/api/v1/status` | System & Edge agent status |
| `GET` | `/api/v1/devices` | List registered edge devices |
| `GET` | `/api/v1/devices/:id` | Get details of a single device |
| `POST` | `/api/v1/inference` | Trigger mock edge AI inference |

### Example Request

```bash
curl -X POST http://localhost:8000/api/v1/inference \
  -H "Content-Type: application/json" \
  -d '{"device_id": "node-esp32-s3-01", "prompt": "Process edge telemetry"}'
```
