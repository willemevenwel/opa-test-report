
# Use Debian-based Node image for Puppeteer/Chromium compatibility
# There is no official Node.js+Chromium image that is always vulnerability-free.
# If you need a "clean" scan for compliance, you must wait for upstream fixes or use a security scanner to ignore non-exploitable CVEs.
FROM node:20-bookworm-slim

RUN apt-get update && apt-get install -y chromium netcat-openbsd \
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

# Copy only required files
COPY rego-coverage-report.html ./
COPY coverage.json ./
COPY entrypoint.sh ./
COPY render_and_exit.sh ./
COPY render.js ./
COPY server.js ./
# Copy only .rego files (test files are excluded by .dockerignore)
COPY *.rego ./

# Use entrypoint.sh for dual-mode (webserver or static render)
ENTRYPOINT ["sh", "entrypoint.sh"]
