FROM espressif/idf:release-v5.3

# Install Node.js (needed for building the web frontend in application/edge_agent/components/http_server)
RUN apt-get update && apt-get install -y ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y nodejs \
    && npm install -g pnpm \
    && rm -rf /var/lib/apt/lists/*

# Set up workspace
WORKDIR /workspace

# Source IDF environment automatically on entry
ENTRYPOINT ["/opt/esp/entrypoint.sh"]
CMD ["/bin/bash"]
