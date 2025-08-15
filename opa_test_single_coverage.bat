@echo off
SETLOCAL

REM Check if exactly two arguments are provided
IF "%~2"=="" (
    echo Usage: %~nx0 ^<policy-file.rego^> ^<test-file.rego^>
    EXIT /B 1
)

SET "POLICY_FILE=%~1"
SET "TEST_FILE=%~2"

REM Run the OPA test command
opa test "%POLICY_FILE%" "%TEST_FILE%" --coverage
 