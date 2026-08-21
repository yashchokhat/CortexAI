#!/bin/bash

# Exit on any error
set -e

echo "======================================"
echo "    CortexAI App Setup Script"
echo "======================================"
echo ""

# 1. Local Flutter setup (if available)
if command -v flutter &> /dev/null
then
    echo "[1/2] Flutter is installed. Getting local dependencies..."
    flutter pub get
else
    echo "[1/2] Flutter CLI not found. Skipping local flutter setup."
    echo "      (You can still run the app via Docker!)"
fi

echo ""

# 2. Docker setup
if command -v docker &> /dev/null
then
    echo "[2/2] Building the Docker image (cortexai-app)..."
    docker build -t cortexai-app .
    echo ""
    echo "======================================"
    echo "          Setup Complete!             "
    echo "======================================"
    echo ""
    echo "To run the Dockerized web app, use:"
    echo "  docker run -p 8080:80 cortexai-app"
    echo ""
    echo "Then open your browser to: http://localhost:8080"
else
    echo "[2/2] Docker CLI not found. Please install Docker to build the container image."
fi
