@echo off
setlocal enabledelayedexpansion

echo DXV Build

set PATH=%PATH%;C:\QuickWriteTerminal\minimal\clang64\bin

set BUILD_DIR=build
set INSTALL_PREFIX=D:/DLLs/CMkL.API
set GENERATOR=Ninja

where clang >nul 2>&1
if errorlevel 1 (
    echo clang.exe not found
    pause
    exit /b 1
)

cmake -B %BUILD_DIR% -S . -G "%GENERATOR%" ^
    -DCMAKE_C_COMPILER=clang ^
    -DCMAKE_CXX_COMPILER=clang++

if errorlevel 1 (
    echo CMake error
    pause
    exit /b 1
)

cmake --build %BUILD_DIR% --config Release

if errorlevel 1 (
    echo Build error
    pause
    exit /b 1
)

cmake --install %BUILD_DIR% --config Release --prefix "%INSTALL_PREFIX%"

if errorlevel 1 (
    echo Install error
    pause
    exit /b 1
)

echo OK

pause