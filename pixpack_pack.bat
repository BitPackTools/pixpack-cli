@echo off

rem Usage: pixpack_pack.bat "path\to\image.png" "path\to\payload" "path\to\out_packed.png" "YourPassword"

if "%~4"=="" (
    echo Usage: %~nx0 "image.png" "payload_file_or_folder" "out_packed.png" "password"
    exit /b 2
)

set "IMAGE=%~1"
set "PAYLOAD=%~2"
set "OUT=%~3"
set "PASSWORD=%~4"

rem --- basic checks
if not exist "%IMAGE%" (
    echo ERROR: Image not found: "%IMAGE%"
    exit /b 3
)
if not exist "%PAYLOAD%" (
    echo ERROR: Payload not found: "%PAYLOAD%"
    exit /b 4
)

set "SEVENS=.\7zr.exe"

rem --- temp archive path
set "TMPARCH=%TEMP%\ppk_payload_%RANDOM%.7z"

echo Creating encrypted 7z archive...
rem - ensure we pass password without space after -p
"%SEVENS%" a "%TMPARCH%" "%PAYLOAD%" -p"%PASSWORD%" -mhe=on >NUL
if errorlevel 1 (
    echo ERROR: 7z failed to create archive.
    if exist "%TMPARCH%" del /f /q "%TMPARCH%" >NUL 2>&1
    exit /b 6
)

rem --- create/overwrite output PNG by copying original
if exist "%OUT%" (
    del /f /q "%OUT%" >NUL 2>&1
)

copy /b "%IMAGE%" "%OUT%" >NUL
if errorlevel 1 (
    echo ERROR: Failed to copy image to "%OUT%".
    del /f /q "%TMPARCH%" >NUL 2>&1
    exit /b 7
)

rem --- append archive bytes to the PNG
rem use copy /b "img"+"arch" out  (works with quoted paths)
copy /b "%OUT%"+ "%TMPARCH%" "%OUT%" >NUL
if errorlevel 1 (
    echo ERROR: Failed to append archive to "%OUT%".
    del /f /q "%TMPARCH%" >NUL 2>&1
    exit /b 8
)

rem cleanup
del /f /q "%TMPARCH%" >NUL 2>&1

echo Done. Packed file: "%OUT%"
exit /b 0
