#!/bin/sh
# Entrypoint for dual-mode: webserver or static render
set -e

if [ "$1" = "web" ]; then
  echo "[Entrypoint] Starting Express webserver on port 3000..."
  exec node server.js
else
  echo "[Entrypoint] Running static render..."
  exec sh render_and_exit.sh "$@"
fi
