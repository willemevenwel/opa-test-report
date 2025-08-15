#!/bin/sh
set -e

# Start the server in the background
echo "ℹ️  - Starting Express webserver on port 3000..."
node server.js &
SERVER_PID=$!
echo "✅ - Node running."

# Wait for the server to be ready
# Try to connect to localhost:3000 up to 10 times
for i in $(seq 1 10); do
  if nc -z localhost 3000; then
    break
  fi
  sleep 1
done


# Use first argument as output file name, default to opa-static-report.html if not provided
OUTPUT_FILE=${1:-opa-static-report.html}
echo "ℹ️  - Starting render.js"
node render.js http://localhost:3000?coverage=coverage.json output/$OUTPUT_FILE
echo "✅ - Render has run render.js"

# Kill the server
kill $SERVER_PID
 