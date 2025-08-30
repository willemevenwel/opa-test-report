
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


1. Run tests and generate reports using Docker (recommended):
      - Build the Docker image (see below), then run:
         ```sh
         docker run --rm -v "$PWD/output:/app/output" opa-test-report
         ```
      - This will generate `coverage.json` and `verbose.txt` in the container, and you can use the web or static report options below.

2. Build the Docker image:
   ```sh
   docker build -t opa-test-report .
   # Or to specify platform:
   docker build --platform=linux/amd64 -t opa-test-report .
   ```
3. **Choose your mode of operation:**

   **Web Server Mode (Interactive Development):**
   ```sh
   docker run --rm -p 3000:3000 opa-test-report web
   ```
   - Visit: [http://localhost:3000](http://localhost:3000)
   - Great for development and testing
   - Auto-refreshes when you rebuild the container

   **Static Report Mode (Sharing/CI):**
   ```sh
   docker run --rm -v "$PWD/output:/app/output" opa-test-report my-report.html
   ```
   - Generates a self-contained HTML file in `output/my-report.html`
   - Perfect for sharing via email, CI/CD artifacts, or static hosting

   **Debug/Manual Mode (Troubleshooting):**
   ```sh
   docker run -it --rm opa-test-report bash
   ```
   - Opens an interactive shell inside the container
   - Run OPA commands manually: `opa test policies/ tests/ --verbose`
   - Inspect files, debug issues, or experiment with policies

4. Generate a static HTML report (using Puppeteer/Chromium):
   ```sh
   docker run --rm -v "$PWD/output:/app/output" opa-test-report custom-report.html
   ```
   - The report will be saved as `output/custom-report.html`.
   - This uses Puppeteer/Chromium to render the HTML as it appears in the browser.

## Expected Output

After running the coverage report, you should see:

### Coverage Metrics
- **Total Coverage Percentage**: Overall percentage of policy lines covered by tests (e.g., 96.77%)
- **Individual Policy Coverage**: Each `.rego` file in your `policies/` directory with its own coverage percentage
- **Line-by-line Coverage**: Color-coded highlighting in the source code:
  - 🟢 **Green lines**: Covered by tests
  - 🔴 **Red lines**: Not covered by tests (need more tests)
  - 🔵 **Blue lines**: Ignored (comments, imports, package declarations)

### Test Results
- **Test Status**: PASS/FAIL for each individual test
- **Execution Time**: How long each test took (slow tests >100ms are highlighted)
- **Test Organization**: Results grouped by policy file for easy navigation

### Output Modes
- **Web Mode** (`web`): Interactive report at http://localhost:3000 - great for development
- **Static Mode** (`filename.html`): Self-contained HTML file - perfect for sharing or CI/CD  
- **Debug Mode** (`bash`): Interactive shell for manual testing and troubleshooting

## Setup


### 1. (Optional) Download OPA manually
If you want to run OPA locally (not via Docker), download the binary for your OS:

#### For macOS (Darwin/amd64):
```sh
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_darwin_amd64
chmod +x opa
```

#### For Windows:
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
   [http://localhost:3000](http://localhost:3000)

## Notes
- The Docker image includes:
   - `rego-coverage-report.html`
   - All `*.rego` files in `policies/`, test files in `tests/`, and data in `test_data/`
   - `entrypoint.sh`, `render_and_exit.sh`, `render.js`, `server.js`, `package.json`
- Make sure your test rules are named with underscores (e.g., `test_allow_admin`) and do not shadow the built-in `input` variable.
- Update the OPA binary download link if you are on a different OS/architecture. See the [OPA downloads page](https://openpolicyagent.org/downloads/latest/) for more options.
- You can repeat the test and coverage steps for other policy/test file pairs (e.g., `policy_two.rego`, `policy_two_test.rego`).

---

## Troubleshooting

### Static Report Shows Only Raw Data
If your generated HTML file shows JSON data instead of formatted tables and charts:
- **Check the render logs**: Look for console output during static generation
- **Verify data files**: Ensure `coverage.json` and `verbose.txt` contain real data, not empty/placeholder content
- **Try web mode first**: Run `docker run --rm -p 3000:3000 opa-test-report web` to verify data loads correctly

### Coverage Shows 0% or Missing Policies
- **Check file structure**: Ensure your `.rego` files are in `policies/` directory
- **Verify test naming**: Test functions must start with `test_` and use `if` keyword
- **Check test data**: Ensure `test_data/` contains valid JSON files matching your policy structure
- **Run tests manually**: Try `docker run -it --rm opa-test-report bash` then `opa test policies/ tests/ --verbose`

### Permission Denied or Volume Mount Issues
- **macOS/Linux**: Ensure Docker has permission to access your project directory
- **Windows**: Check that your drive is shared with Docker Desktop
- **Path issues**: Use absolute paths or ensure you're in the project root when running commands

### Stopping a Stuck Web Server

If you try to start the Node web server and get an error that port 3000 is already in use, you may have a previous server process still running. To stop it:

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