@echo off
setlocal enabledelayedexpansion

echo 0 done.
echo DXV Build

set PATH=%PATH%;C:\QuickWriteTerminal\minimal\clang64\bin

set BUILD_DIR=build
set INSTALL_PREFIX=D:/DLLs/CMkL.API
set GENERATOR=Ninja

where clang >nul 2>&1
if errorlevel 1 (
    echo 0% done. clang.exe not found in PATH
    echo Make sure you are running this from the MSYS2 CLANG64 shell.
    pause
    exit /b 1
)

echo 1 done. 
echo Using:
clang --version
echo.

echo 2 done. Starting CMake.
cmake -B %BUILD_DIR% -S . -G "%GENERATOR%" ^
    -DCMAKE_C_COMPILER=clang ^
    -DCMAKE_CXX_COMPILER=clang++

if errorlevel 1 (
    echo 2 done. Starting CMake failed.
    pause
    exit /b 1
)

echo.
echo 3 done. Building library.
cmake --build %BUILD_DIR% --config Release

if errorlevel 1 (
    echo 3 done. Build failed.
    pause
    exit /b 1
)

echo.
echo 4 done. Installing.
cmake --install %BUILD_DIR% --config Release --prefix "%INSTALL_PREFIX%"

if errorlevel 1 (
    echo 4 done. Install failed.
    pause
    exit /b 1
)

echo.
echo 5 done. Find the library in %INSTALL_PREFIX%\bin

pause