#!/bin/bash

# Set the name of the output zip file
ZIP_NAME="rego_bundle.zip"

# Remove existing zip if it exists
[ -f "$ZIP_NAME" ] && rm "$ZIP_NAME"

# Create a temporary directory
TEMP_DIR="rego_temp"
mkdir -p "$TEMP_DIR"

# Copy all .rego files that do NOT contain '_test' in the name
for file in *.rego; do
    if [[ "$file" != *_test.rego ]]; then
        cp "$file" "$TEMP_DIR/"
    fi
done

cp "coverage.json" "$TEMP_DIR/"

cp "rego-coverage-report.html" "$TEMP_DIR/"

# Create the zip archive
zip -r "$ZIP_NAME" "$TEMP_DIR" > /dev/null

# Clean up
rm -r "$TEMP_DIR"

echo "Done! Created $ZIP_NAME with non-test .rego files."
 