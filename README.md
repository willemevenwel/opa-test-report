# OPA Test Report

This project demonstrates how to write, test, and generate coverage reports for Open Policy Agent (OPA) Rego policies.

## Prerequisites

- **Python 3** (for serving the coverage report via HTTP)
- **curl** (for downloading OPA)
- **bash** (for running the test script)
- **macOS** (the OPA binary in the example is for Darwin/amd64)

## Setup

1. **Download OPA:**
   ```sh
   curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_darwin_amd64
   chmod +x opa
   ```

2. **Write your Rego policies and tests**
   - Place your policy files (e.g., `policy_one.rego`, `policy_two.rego`) and corresponding test files (e.g., `policy_one_test.rego`, `policy_two_test.rego`) in the project directory.
   - Test rules must start with `test_` and use the `if` keyword (required for OPA >= 0.47.0).

3. **Run OPA tests and generate coverage:**
   ```sh
   ./opa-test-single-coverage.sh policy_one.rego policy_one_test.rego > coverage.json
   ```
   - This script runs your tests and outputs a coverage report in `coverage.json`.

4. **Serve the coverage report locally:**
   ```sh
   python3 -m http.server 8000
   ```
   - This will start a local server at [http://localhost:8000](http://localhost:8000)

5. **View the coverage report:**
   - Open your browser and go to:
     [http://localhost:8000/rego-coverage-report.html?file=policy_one.rego&coverage=coverage.json](http://localhost:8000/rego-coverage-report.html?file=policy_one.rego&coverage=coverage.json)

## Notes
- Make sure your test rules are named with underscores (e.g., `test_allow_admin`) and do not shadow the built-in `input` variable.
- Update the OPA binary download link if you are on a different OS/architecture.
- You can repeat the test and coverage steps for other policy/test file pairs (e.g., `policy_two.rego`, `policy_two_test.rego`).

---

Happy policy testing!


