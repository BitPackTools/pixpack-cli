@echo off

setlocal

rem --- 1) Source PNG
if "%~1"=="" (
    for /f "delims=" %%I in ('powershell -NoProfile -STA -Command "Add-Type -AssemblyName System.Windows.Forms; $ofd = New-Object System.Windows.Forms.OpenFileDialog; $ofd.Title = ''Select the PNG file.''; $ofd.Filter = ''PNG files (*.png)|*.png''; $ofd.DefaultExt = ''png''; if($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){ Write-Output $ofd.FileName }"') do set "IMAGE=%%I"
) else (
    set "IMAGE=%~1"
)

if "%IMAGE%"=="" (
    echo Cancelled or no image selected.
    goto :end
)
echo Selected image: "%IMAGE%"

rem --- 2) Select payload (file)
for /f "delims=" %%I in ('powershell -NoProfile -STA -Command "Add-Type -AssemblyName System.Windows.Forms; $ofd2 = New-Object System.Windows.Forms.OpenFileDialog; $ofd2.Title = 'Select the file you want to package.'; if($ofd2.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){ Write-Output $ofd2.FileName }"') do set "PAYLOAD=%%I"

if "%PAYLOAD%"=="" (
    echo Cancelled or no payload selected.
    goto :end
)
echo Selected payload: "%PAYLOAD%"

rem --- 3) SaveFileDialog
for /f "delims=" %%I in ('powershell -NoProfile -STA -Command "Add-Type -AssemblyName System.Windows.Forms; $dlg = New-Object System.Windows.Forms.SaveFileDialog; $dlg.Title = 'Select or enter the PNG file to create'; $dlg.Filter = 'PNG files (*.png)|*.png'; $dlg.DefaultExt = 'png'; if($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){ Write-Output $dlg.FileName }"') do set "OUT=%%I"

if "%OUT%"=="" (
    echo Cancelled or no output selected.
    goto :end
)
echo Output file: "%OUT%"

rem --- 4) Password prompt (masked)
for /f "delims=" %%I in ('powershell -NoProfile -STA -Command "Add-Type -AssemblyName System.Windows.Forms; $form = New-Object System.Windows.Forms.Form; $form.Text = 'Enter Password'; $form.Size = New-Object System.Drawing.Size(360,150); $form.StartPosition = 'CenterScreen'; $label = New-Object System.Windows.Forms.Label; $label.Text='Enter your password:'; $label.AutoSize=$true; $label.Location = New-Object System.Drawing.Point(10,20); $form.Controls.Add($label); $textbox = New-Object System.Windows.Forms.TextBox; $textbox.Location = New-Object System.Drawing.Point(10,45); $textbox.Size = New-Object System.Drawing.Size(320,20); $textbox.UseSystemPasswordChar = $true; $form.Controls.Add($textbox); $ok = New-Object System.Windows.Forms.Button; $ok.Text='OK'; $ok.Location = New-Object System.Drawing.Point(250,75); $ok.Add_Click({$form.DialogResult = [System.Windows.Forms.DialogResult]::OK; $form.Close()}); $form.Controls.Add($ok); $cancel = New-Object System.Windows.Forms.Button; $cancel.Text='Cancel'; $cancel.Location = New-Object System.Drawing.Point(170,75); $cancel.Add_Click({$form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; $form.Close()}); $form.Controls.Add($cancel); if($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){ Write-Output $textbox.Text }"') do set "PASSWORD=%%I"

if "%PASSWORD%"=="" (
    echo Cancelled or no password entered.
    goto :end
)
echo Password captured (not displayed).


rem --- basic checks
if not exist "%IMAGE%" (
    echo ERROR: Image not found: "%IMAGE%"
    exit /b 3
)
if not exist "%PAYLOAD%" (
    echo ERROR: Payload not found: "%PAYLOAD%"
    exit /b 4
)

set "SEVENS=%~dp07zr.exe"

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
