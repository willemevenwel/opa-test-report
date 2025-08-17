# OPA Test Report

This project demonstrates how to write, test, and generate coverage reports for Open Policy Agent (OPA) Rego policies.

## Prerequisites

- **Docker** (for serving the coverage report via HTTP)
- **curl** (for downloading OPA)
- **bash** or **cmd** (for running the test script)
- **macOS or Windows** (see OPA download instructions below)

## Quick Start

1. Run all tests: <code>run_opa_tests.sh</code> or <code>run_opa_tests.bat</code>
   - Dependant on the opa executable
2. Compile Docker image: <code>docker build -t opa-test-report .</code>
3. Run as a webserver (port 3000): <code>docker run --rm -p 3000:3000 opa-test-report web</code>
   - Visit: [http://localhost:3000](http://localhost:3000)
4. Generate a static HTML report: <code>docker run --rm -v "$PWD/output:/app/output" opa-test-report custom-report.html</code>
   - The report will be saved as <code>output/custom-report.html</code>.

## Setup

### 1. Download OPA

#### For macOS (Darwin/amd64):
```sh
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_darwin_amd64
chmod +x opa
```

#### For Windows:
Download the OPA executable for Windows:
```sh
curl -L -o opa.exe https://openpolicyagent.org/downloads/latest/opa_windows_amd64.exe
```
Or download manually from: [https://openpolicyagent.org/downloads/latest/](https://openpolicyagent.org/downloads/latest/)

### 2. Write your Rego policies and tests
- Place your policy files (e.g., `policy_one.rego`, `policy_two.rego`) and corresponding test files (e.g., `policy_one_test.rego`, `policy_two_test.rego`) in the project directory.
- Test rules must start with `test_` and use the `if` keyword (required for OPA >= 0.47.0).

### 3. Run all OPA tests in the project using Makefile

## Makefile Usage

This project includes a `Makefile` to simplify running OPA tests and generating coverage reports. You can use the following commands:

### Global Targets

- `make test` — Run all tests for all policies and test data.
- `make test-verbose` — Run all tests with verbose output.
- `make coverage` — Run all tests and generate a coverage report (`{root}/coverage.json`).

### Per-Entity Targets

For each entity (e.g., `order_service/invoice`, `user_service/teacher`), you can run tests or generate coverage for just that entity:

- `make test-<entity>` — Run tests for a specific entity (e.g., `make test-order_service/invoice`).
- `make test-<entity>-verbose` — Run verbose tests for a specific entity.
- `make coverage-<entity>` — Generate coverage for a specific entity.

### Per-Service Targets

For each service (e.g., `order_service`, `user_service`), you can run all tests or generate coverage for that service:

- `make test-<service>` — Run all tests for a service (e.g., `make test-order_service`).
- `make test-<service>-verbose` — Run all tests for a service with verbose output.
- `make coverage-<service>` — Generate coverage for a service.

### List All Available Targets

- `make list-tests` — List all available per-entity and per-service targets.

---

### 4. Serve or generate the coverage report using Docker

- **To run as a webserver (port 3000):**
   ```sh
   docker run --rm -p 3000:3000 opa-test-report web
   ```
   Visit: [http://localhost:3000](http://localhost:3000)

- **To generate a static HTML report:**
   ```sh
   docker run --rm -v "$PWD/output:/app/output" opa-test-report custom-report.html
   ```
   The report will be saved as <code>output/custom-report.html</code>.

### 5. View the coverage report
- Open your browser and go to:
   [http://localhost:3000/?coverage=coverage.json](http://localhost:3000/?coverage=coverage.json)


## Notes
- Only the following files are included in the Docker image:
   - `rego-coverage-report.html`
   - `coverage.json`
   - All `*.rego` files (except `*_test.rego` are not used in the container)
   - `entrypoint.sh`
   - `render_and_exit.sh`
   - `render.js`
   - `server.js`
   - `package.json`
- Make sure your test rules are named with underscores (e.g., `test_allow_admin`) and do not shadow the built-in `input` variable.
- Update the OPA binary download link if you are on a different OS/architecture. See the [OPA downloads page](https://openpolicyagent.org/downloads/latest/) for more options.
- You can repeat the test and coverage steps for other policy/test file pairs (e.g., `policy_two.rego`, `policy_two_test.rego`).

---

## Troubleshooting: Stopping a Stuck Web Server

If you try to start the Python web server and get an error that port 3000 is already in use, you may have a previous server process still running. To stop it:

1. Find the process using port 3000:
   ```sh
   lsof -i :3000
   ```
2. Kill the process (replace <PID> with the process ID from the previous command):
   ```sh
   kill -9 <PID>
   ```

This will free up port 3000 so you can restart the server.

---

Happy policy testing!