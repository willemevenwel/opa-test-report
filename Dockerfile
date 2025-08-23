
# Use Debian-based Node image for Puppeteer/Chromium compatibility
# There is no official Node.js+Chromium image that is always vulnerability-free.
# If you need a "clean" scan for compliance, you must wait for upstream fixes or use a security scanner to ignore non-exploitable CVEs.
FROM node:21-bookworm-slim

RUN apt-get update && apt-get install -y chromium netcat-openbsd curl \
    && rm -rf /var/lib/apt/lists/*

# Puppeteer will use system Chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json (if present)
COPY package.json ./

# Install Chromium
# Install Node dependencies
RUN npm install --production

# Download opa binary and add /app to PATH
RUN curl -fL -o opa \
    https://openpolicyagent.org/downloads/latest/opa_linux_amd64 \
    #https://openpolicyagent.org/downloads/latest/opa_darwin_amd64 \
    #https://openpolicyagent.org/downloads/latest/opa_windows_amd64.exe \
    && chmod +x opa
ENV PATH="/app:$PATH"

# Copy only required files
COPY polly.png ./
COPY rego-coverage-report.html ./
COPY entrypoint.sh ./
COPY render_and_exit.sh ./
COPY render.js ./
COPY server.js ./

# Copy only .rego files (test files are excluded by .dockerignore)
# Copy all rego files and directory structure from policies folder
COPY policies/ ./policies/
COPY tests/ ./tests/
COPY test_data/ ./test_data/

# Use entrypoint.sh for dual-mode (webserver or static render)
ENTRYPOINT ["sh", "entrypoint.sh"]
