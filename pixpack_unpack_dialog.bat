@echo off

setlocal

rem --- 1) Source PNG
if "%~1"=="" (
    for /f "delims=" %%I in ('powershell -NoProfile -STA -Command "Add-Type -AssemblyName System.Windows.Forms; $ofd = New-Object System.Windows.Forms.OpenFileDialog; $ofd.Title = ''Select the PNG file.''; $ofd.Filter = ''PNG files (*.png)|*.png''; $ofd.DefaultExt = ''png''; if($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){ Write-Output $ofd.FileName }"') do set "PACKED=%%I"
) else (
    set "PACKED=%~1"
)


rem --- 2) Select OUTDIR
for /f "delims=" %%I in ('powershell -NoProfile -STA -Command "Add-Type -AssemblyName System.Windows.Forms; $fbd = New-Object System.Windows.Forms.FolderBrowserDialog; $fbd.Description = 'Select a folder'; if($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){ Write-Output $fbd.SelectedPath }"') do set "OUTDIR=%%I"

if "%OUTDIR%"=="" (
    echo Cancelled or no outdir selected.
    goto :end
)
echo Selected image: "%OUTDIR%"

rem --- 3) Password prompt (masked)
for /f "delims=" %%I in ('powershell -NoProfile -STA -Command "Add-Type -AssemblyName System.Windows.Forms; $form = New-Object System.Windows.Forms.Form; $form.Text = 'Enter Password'; $form.Size = New-Object System.Drawing.Size(360,150); $form.StartPosition = 'CenterScreen'; $label = New-Object System.Windows.Forms.Label; $label.Text='Enter your password:'; $label.AutoSize=$true; $label.Location = New-Object System.Drawing.Point(10,20); $form.Controls.Add($label); $textbox = New-Object System.Windows.Forms.TextBox; $textbox.Location = New-Object System.Drawing.Point(10,45); $textbox.Size = New-Object System.Drawing.Size(320,20); $textbox.UseSystemPasswordChar = $true; $form.Controls.Add($textbox); $ok = New-Object System.Windows.Forms.Button; $ok.Text='OK'; $ok.Location = New-Object System.Drawing.Point(250,75); $ok.Add_Click({$form.DialogResult = [System.Windows.Forms.DialogResult]::OK; $form.Close()}); $form.Controls.Add($ok); $cancel = New-Object System.Windows.Forms.Button; $cancel.Text='Cancel'; $cancel.Location = New-Object System.Drawing.Point(170,75); $cancel.Add_Click({$form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; $form.Close()}); $form.Controls.Add($cancel); if($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){ Write-Output $textbox.Text }"') do set "PASSWORD=%%I"

if "%PASSWORD%"=="" (
    echo Cancelled or no password entered.
    goto :end
)
echo Password captured (not displayed).


rem basic checks
if not exist "%PACKED%" (
    echo ERROR: Packed file not found: "%PACKED%"
    exit /b 3
)

set "SEVENS=%~dp07zr.exe"

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