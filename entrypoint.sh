#!/bin/sh
# Entrypoint for dual-mode: webserver or static render
set -e

if [ "$1" = "web" ]; then
  echo "ℹ️  - Starting Express webserver on port 3000..."
  exec node server.js
  echo "✅ - Node running."
else
  echo "ℹ️  - Running static render..."
  exec sh render_and_exit.sh "$@"
  echo "✅ - Static render has run."
fi
 