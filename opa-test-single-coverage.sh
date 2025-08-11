#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <policy-file.rego> <test-file.rego>"
  exit 1
fi

POLICY_FILE=$1
TEST_FILE=$2

./opa test "$POLICY_FILE" "$TEST_FILE" --coverage --format=pretty
