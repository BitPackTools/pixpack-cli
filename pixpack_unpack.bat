@echo off
rem Usage: pixpack_unpack.bat "packed_file" "out_directory" "password"
if "%~3"=="" (
    echo Usage: %~nx0 "packed_file" "out_directory" "password"
    exit /b 2
)
set "PACKED=%~1"
set "OUTDIR=%~2"
set "PASSWORD=%~3"

rem basic checks
if not exist "%PACKED%" (
    echo ERROR: Packed file not found: "%PACKED%"
    exit /b 3
)

set "SEVENS=.\7zr.exe"

rem ensure output dir exists
if not exist "%OUTDIR%" (
    mkdir "%OUTDIR%" >NUL 2>&1
    if errorlevel 1 (
        echo ERROR: Could not create output dir: "%OUTDIR%"
        exit /b 5
    )
)

rem create temporary .zip filename next to the packed file
for %%i in ("%PACKED%") do set "PACKEDDIR=%%~dpi"
set "TMPARCH=%PACKEDDIR%payload_temp_%RANDOM%.zip"

rem Copy the packed file to tmp .zip
echo Preparing temporary archive...
copy /b "%PACKED%" "%TMPARCH%" >NUL
if errorlevel 1 (
    echo ERROR: Failed to copy "%PACKED%" to "%TMPARCH%".
    exit /b 6
)

rem Try to extract
echo Extracting to "%OUTDIR%" ...
"%SEVENS%" x "%TMPARCH%" -o"%OUTDIR%" -p"%PASSWORD%" -y

rem Save the return code before cleanup
set "RC=%ERRORLEVEL%"

rem cleanup temporary archive
if exist "%TMPARCH%" del /f /q "%TMPARCH%" >NUL 2>&1

if "%RC%"=="0" (
    echo Extraction completed successfully.
    exit /b 0
) else (
    echo ERROR: 7z returned exit code %RC%. Extraction may have failed.
    exit /b %RC%
)