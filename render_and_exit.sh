#!/bin/sh
set -e

# Start the server in the background
node server.js &
SERVER_PID=$!

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
node render.js http://localhost:3000?coverage=coverage.json coverage.json output/$OUTPUT_FILE

# Kill the server
kill $SERVER_PID
