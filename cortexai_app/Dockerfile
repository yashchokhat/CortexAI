# Stage 1: Build the Flutter web app
FROM debian:latest AS build-env

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl git wget unzip gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3 ca-certificates && \
    apt-get clean

# Clone the flutter repo
RUN git clone -b stable --depth 1 https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Enable web support (often enabled by default on stable, but good to be sure)
RUN flutter config --enable-web

# Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/

# Get dependencies
RUN flutter pub get

# Build the web app
RUN flutter build web

# Stage 2: Serve the app with Nginx
FROM nginx:alpine

# Copy the build output from the first stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
