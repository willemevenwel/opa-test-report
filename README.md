# OPA Test Report

This project demonstrates how to write, test, and generate coverage reports for Open Policy Agent (OPA) Rego policies.

## Prerequisites

- **Docker** (for serving the coverage report via HTTP)
- **curl** (for downloading OPA)
- **bash** or **cmd** (for running the test script)
- **macOS or Windows** (see OPA download instructions below)

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

### 3. Run all OPA tests in the project
From the project root, run:
```sh
./run_opa_tests.sh
```
- On Windows, use:
```sh
run_opa_tests.bat
```
This will discover and run all tests in all `.rego` files in the current directory and subdirectories. And save the coverage report as `coverage.json`.

### 4. Run OPA tests and generate coverage for a single policy and test
```sh
./opa-test-single-coverage.sh policy_one.rego policy_one_test.rego > coverage.json
```
- On Windows, you may need to use Git Bash or WSL to run the shell script, or adapt the script for PowerShell.
- This script runs your tests and outputs a coverage report in `coverage.json`.

### 5. Serve the coverage report using a Docker nginx container

- Run the bundle package script
- this creates the rego_bundle.zip with all your rego policies the data and the report html.

```sh
./bundle_rego.sh
```
or on windows:
```sh
bundle_rego.bat 
```

- Compile the docker image: 
```sh
docker build -t opa-test-report
```
- Run the docker image:
- This will start a local server at [http://localhost:8080](http://localhost:8080)
```sh
docker run -p 8080:80 opa-test-report
```

### 6. View the coverage report
- Open your browser and go to:
  [http://localhost:8000/rego-coverage-report.html?file=policy_one.rego&coverage=coverage.json](http://localhost:8000/rego-coverage-report.html?file=policy_one.rego&coverage=coverage.json)

## Notes
- Make sure your test rules are named with underscores (e.g., `test_allow_admin`) and do not shadow the built-in `input` variable.
- Update the OPA binary download link if you are on a different OS/architecture. See the [OPA downloads page](https://openpolicyagent.org/downloads/latest/) for more options.
- You can repeat the test and coverage steps for other policy/test file pairs (e.g., `policy_two.rego`, `policy_two_test.rego`).

---

## Troubleshooting: Stopping a Stuck Web Server

If you try to start the Python web server and get an error that port 8000 is already in use, you may have a previous server process still running. To stop it:

1. Find the process using port 8000:
   ```sh
   lsof -i :8000
   ```
2. Kill the process (replace <PID> with the process ID from the previous command):
   ```sh
   kill -9 <PID>
   ```

This will free up port 8000 so you can restart the server.

---

Happy policy testing!