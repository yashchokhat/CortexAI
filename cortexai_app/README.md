# CortexAI App

A modern Flutter application featuring a custom loading screen and a containerized web deployment setup.

## Features

- **Loading Screen**: A built-in loading page (`lib/loading_page.dart`) that greets users before transitioning into the main application.
- **Dockerized Web App**: Fully configured with a multi-stage `Dockerfile` to build the Flutter web version and serve it blazingly fast using NGINX.

## Getting Started Locally

If you have [Flutter](https://docs.flutter.dev/get-started/install) installed on your machine, you can run the app locally:

1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Run the application (select your preferred device/emulator):
   ```bash
   flutter run
   ```

## Docker Setup

You can build and run the app without needing Flutter installed on your local machine by using Docker.

1. Build the Docker image:
   ```bash
   docker build -t cortexai-app .
   ```
2. Run the container:
   ```bash
   docker run -p 8080:80 cortexai-app
   ```
3. Open your browser and navigate to `http://localhost:8080`.

## Automated Setup Script

For convenience, a `setup.sh` script is provided to automate the initial setup and Docker build process.

1. Make the script executable:
   ```bash
   chmod +x setup.sh
   ```
2. Run the script:
   ```bash
   ./setup.sh
   ```
