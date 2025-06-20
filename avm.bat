@echo off
SETLOCAL

REM Set CONTAINER_RUNTIME to its current value if it's already set, or docker if it's not
IF DEFINED CONTAINER_RUNTIME (SET "CONTAINER_RUNTIME=%CONTAINER_RUNTIME%") ELSE (SET "CONTAINER_RUNTIME=docker")

REM Check if CONTAINER_RUNTIME is installed
WHERE /Q %CONTAINER_RUNTIME%
IF ERRORLEVEL 1 (
    echo Error: %CONTAINER_RUNTIME% is not installed. Please install %CONTAINER_RUNTIME% first.
    exit /b
)

IF DEFINED AVM_IMAGE (SET "AVM_IMAGE=%AVM_IMAGE%") ELSE (SET "AVM_IMAGE=mcr.microsoft.com/azterraform")

REM Check if a make target is provided
IF "%~1"=="" (
    echo Error: Please provide a make target. See https://github.com/Azure/tfmod-scaffold/blob/main/avmmakefile for available targets.
    exit /b
)

IF DEFINED NO_PULL (
    SET "PULL_ARG="
) ELSE (
    SET "PULL_ARG=--pull always"
)

REM Run the make target with CONTAINER_RUNTIME
%CONTAINER_RUNTIME% run %PULL_ARG% --rm -v "%cd%":/src -w /src --user "1000:1000" -e GITHUB_TOKEN -e ARM_SUBSCRIPTION_ID -e ARM_TENANT_ID -e ARM_CLIENT_ID -e GITHUB_REPOSITORY -e GITHUB_REPOSITORY_OWNER %AVM_IMAGE% make %1

ENDLOCAL
