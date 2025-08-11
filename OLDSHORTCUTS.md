curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_darwin_amd64

chmod +x opa

./opa-test-single-coverage.sh policy_one.rego policy_one_test.rego

python3 -m http.server 8000

http://localhost:8000/rego-coverage-report.html?file=policy_one.rego&coverage=coverage.json


