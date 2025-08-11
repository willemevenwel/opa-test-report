#!/bin/bash

# Collect all .rego files in the current directory
files=$(ls *.rego 2>/dev/null)

# Check if any .rego files were found
if [ -z "$files" ]; then
  echo "No .rego files found in the current directory."
  exit 1
fi

# Run opa test with coverage
./opa test $files --coverage > coverage.json
 