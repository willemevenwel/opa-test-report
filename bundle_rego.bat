@echo off

setlocal enabledelayedexpansion

:: Set the name of the output zip file
set ZIP_NAME=rego_bundle.zip

:: Remove existing zip if it exists
if exist %ZIP_NAME% del %ZIP_NAME%

:: Create a temporary folder
set TEMP_DIR=rego_temp

mkdir %TEMP_DIR%

:: Copy matching .rego files to the temp folder
for %%f in (*.rego) do (

    echo %%f | findstr /v "_test" >nul

    if !errorlevel! == 0 (

        copy "%%f" "%TEMP_DIR%\"

    )

)

copy "coverage.json" "%TEMP_DIR%\"

copy "rego-coverage-report.html" "%TEMP_DIR%\"

:: Use PowerShell to create the zip file
powershell -Command "Compress-Archive -Path '%TEMP_DIR%\*' -DestinationPath '%ZIP_NAME%'"

:: Clean up
rmdir /s /q %TEMP_DIR%

echo Done! Created %ZIP_NAME% with non-test .rego files. 