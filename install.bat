@echo off
setlocal enabledelayedexpansion

rem Full paths to the batch files (assumes they are in the same folder as this installer)
set "PACKBAT=%~dp0pixpack_pack_dialog.bat"
set "UNPACKBAT=%~dp0pixpack_unpack_dialog.bat"

rem Escape backslashes for .reg file
set "PACKBAT_ESC=%PACKBAT:\=\\%"
set "UNPACKBAT_ESC=%UNPACKBAT:\=\\%"

rem Temporary .reg file path
set "REGFILE=%TEMP%\pixpack_install.reg"

rem Write the .reg file
(
  echo Windows Registry Editor Version 5.00
  echo.
  rem Pack CLI
  echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.png\shell\PixPack]
  echo @="Pack with PixPack"
  echo.
  echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.png\shell\PixPack\command]
  echo @="cmd /k \"\"%PACKBAT_ESC%\" \"%%1\"\""
  echo.
  rem Unpack CLI
  echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.png\shell\PixPack_Unpack]
  echo @="Unpack with PixPack"
  echo.
  echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.png\shell\PixPack_Unpack\command]
  echo @="cmd /k \"\"%UNPACKBAT_ESC%\" \"%%1\"\""
) > "%REGFILE%"

echo Created: %REGFILE%
type "%REGFILE%"
echo.

rem Import the registry file (requires administrator privileges)
reg import "%REGFILE%"
if errorlevel 1 (
  echo An error occurred during registry import. Did you run this as Administrator?
) else (
  echo Context menu successfully installed.
)

rem (optional) delete the temporary .reg file
rem del "%REGFILE%"

endlocal
pause
