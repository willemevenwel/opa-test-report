
<div align="center">
   <img src="polly.png" alt="Polly logo" width="200"/>
   <h1>Polly (OPA) Test Report</h1>
</div>

This project demonstrates how to write, test, and generate coverage reports for Open Policy Agent (OPA) Rego policies.

## Prerequisites

- **Docker** (for serving the coverage report via HTTP)
- **curl** (for downloading OPA)
- **bash** or **cmd** (for running the test script)
- **macOS or Windows** (see OPA download instructions below)

## Quick Start

1. Run tests using the `polly.sh` script:
    - Make sure the `opa` binary is present in the project root (see Setup below).
    - Usage examples:
       - Run all tests:
          ```sh
          ./polly.sh all
          ```
       - List available services and entities:
          ```sh
          ./polly.sh list
          ```
       - See `./polly.sh` for more usage details.

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


### 2. Write your Rego policies, tests, and test data
- Place your policy files in the `policies/` directory, organized by service and entity. For example:
   - `policies/order_service/invoice/allow.rego`
   - `policies/user_service/teacher/validate.rego`
- Place your test files in the corresponding `tests/` directory, mirroring the structure of your policies. For example:
   - `tests/order_service/invoice/allow.rego`
   - `tests/user_service/teacher/validate.rego`
- Place your test data files in the `test_data/` directory, also mirroring the structure. For example:
   - `test_data/order_service/invoice/data.json`
   - `test_data/user_service/teacher/data.json`
- Test rules must start with `test_` and use the `if` keyword (required for OPA >= 0.47.0).

## polly.sh Usage

The `polly.sh` script provides a flexible way to run OPA tests and generate coverage reports. It supports running tests for all policies, or for any specific service, entity, directory, or policy file by simply providing the path as the first argument. It also supports coverage and verbose output options.

### Usage

```
./polly.sh [all|list|<path>] [--coverage <output.json>] [--verbose]
```

#### Examples

- Run all tests:
   ```sh
   ./polly.sh all
   ```
- List available services and entities:
   ```sh
   ./polly.sh list
   ```
- Run tests for a service:
   ```sh
   ./polly.sh service order_service
   ```
- Run tests for an entity:
   ```sh
   ./polly.sh order_service/invoice
   ```
- Run tests for a specific policy file or directory:
   ```sh
   ./polly.sh order_service/invoice/validate
   ./polly.sh order_service/invoice
   ```
- Generate a coverage report:
   ```sh
   ./polly.sh all --coverage 
   ./polly.sh all --coverage coverage.json
   ```
- Run with verbose output:
   ```sh
   ./polly.sh all --verbose
   ./polly.sh all --verbose verbose.txt
   ```
- All together:
   ```sh
   ./polly.sh order_service/invoice/validate --verbose verbose.txt
   ./polly.sh user_service/student/allow --coverage coverage.json
   ```

See the top of `polly.sh` for more details and options.

### 3. Serve or generate the coverage report using Docker

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

### 4. View the coverage report
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