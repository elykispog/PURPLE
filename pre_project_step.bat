@echo off

where cmake >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: CMake is missing! CMake is required to compile Undertale Purple
    exit /b 1
)

cd /d "%~dp0extensions"

for /d %%G in (*) do (
    echo Building %%G...
    pushd "%%G"

    cmake -S . -B build
    if errorlevel 1 exit /b 1

    cmake --build build --config Release
    if errorlevel 1 exit /b 1

    set "DLL=%%~nG.dll"

    if exist "build\Release\%%~nG.dll" (
        copy /Y "build\Release\%%~nG.dll" "."
        echo Copied %%~nG.dll
    ) else (
        echo Warning: build\Release\%%~nG.dll not found.
    )

    popd
)