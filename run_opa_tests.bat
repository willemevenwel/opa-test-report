@echo off
setlocal enabledelayedexpansion

set FILES=
for %%f in (*.rego) do (
    set FILES=!FILES! %%f
)

opa.exe test %FILES% --coverage > coverage.json
 