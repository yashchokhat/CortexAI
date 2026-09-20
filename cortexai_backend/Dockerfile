# syntax=docker/dockerfile:1

# ------------------------------------------------------------------------------
# Stage 1: Build static Go executable
# ------------------------------------------------------------------------------
FROM golang:alpine AS builder

WORKDIR /app

ENV GOTOOLCHAIN=auto

# Install git and ca-certificates if needed for module downloads
RUN apk add --no-cache git ca-certificates tzdata

# Copy module definitions and pre-download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Compile static binary for Linux with optimizations
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o cortexai_backend main.go

# ------------------------------------------------------------------------------
# Stage 2: Minimal, secure runtime container
# ------------------------------------------------------------------------------
FROM alpine:3.20

WORKDIR /app

# Install CA certificates and curl for container healthcheck
RUN apk --no-cache add ca-certificates curl tzdata

# Create non-root user for security
RUN addgroup -S cortex && adduser -S cortex -G cortex

# Copy binary from builder stage
COPY --from=builder /app/cortexai_backend /app/cortexai_backend

# Set ownership
RUN chown -R cortex:cortex /app

USER cortex

# Set production environment variables
ENV PORT=8000
ENV GIN_MODE=release

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

ENTRYPOINT ["/app/cortexai_backend"]
