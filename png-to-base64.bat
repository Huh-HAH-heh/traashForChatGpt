@echo off
chcp 65001 >nul
setlocal EnableExtensions DisableDelayedExpansion

rem ==========================================
rem SETTINGS
rem ==========================================

set "ROOT=%~dp0"
set "INPUT=%ROOT%resorses"
set "OUTPUT=%ROOT%path"
set "CHUNK_SIZE=200"

echo.
echo ==========================================
echo       MASS FILE PROCESSOR
echo ==========================================
echo.
echo Input:
echo "%INPUT%"
echo.
echo Output:
echo "%OUTPUT%"
echo.

if not exist "%INPUT%" (
    echo ERROR: Folder resorses not found.
    echo.
    pause
    exit /b 1
)

if not exist "%OUTPUT%" (
    mkdir "%OUTPUT%"
)

rem ==========================================
rem ENVIRONMENT FOR POWERSHELL
rem ==========================================

set "BT_INPUT=%INPUT%"
set "BT_OUTPUT=%OUTPUT%"
set "BT_CHUNK_SIZE=%CHUNK_SIZE%"

rem ==========================================
rem CREATE TEMP POWERSHELL SCRIPT
rem IMPORTANT:
rem SCRIPT CONTAINS ASCII ONLY
rem ==========================================

set "PSFILE=%TEMP%\file_processor_%RANDOM%_%RANDOM%.ps1"

> "%PSFILE%" echo $ErrorActionPreference = 'Stop'
>>"%PSFILE%" echo $inputDir = [IO.Path]::GetFullPath($env:BT_INPUT)
>>"%PSFILE%" echo $outputDir = [IO.Path]::GetFullPath($env:BT_OUTPUT)
>>"%PSFILE%" echo $chunkSize = [int]$env:BT_CHUNK_SIZE * 1024
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host ''
>>"%PSFILE%" echo Write-Host 'Scanning input directory...' -ForegroundColor Cyan
>>"%PSFILE%" echo.
>>"%PSFILE%" echo $files = @(Get-ChildItem -LiteralPath $inputDir -File -Recurse)
>>"%PSFILE%" echo.
>>"%PSFILE%" echo if ($files.Count -eq 0) {
>>"%PSFILE%" echo     Write-Host 'ERROR: No files found.' -ForegroundColor Red
>>"%PSFILE%" echo     exit 2
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host ('Files found: ' + $files.Count) -ForegroundColor Green
>>"%PSFILE%" echo.
>>"%PSFILE%" echo $number = 1
>>"%PSFILE%" echo.
>>"%PSFILE%" echo while (Test-Path -LiteralPath (Join-Path $outputDir $number)) {
>>"%PSFILE%" echo     $number++
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo foreach ($file in $files) {
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     Write-Host '==========================================' -ForegroundColor DarkGray
>>"%PSFILE%" echo     Write-Host ('FILE ' + $number + ': ' + $file.Name) -ForegroundColor Cyan
>>"%PSFILE%" echo     Write-Host ('SIZE: ' + ('{0:N2}' -f ($file.Length / 1MB)) + ' MB')
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     $dir = Join-Path $outputDir $number
>>"%PSFILE%" echo     New-Item -ItemType Directory -Path $dir -Force ^| Out-Null
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     # ------------------------------------------
>>"%PSFILE%" echo     # COPY ORIGINAL FILE
>>"%PSFILE%" echo     # ------------------------------------------
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     $originalPath = Join-Path $dir $file.Name
>>"%PSFILE%" echo     Copy-Item -LiteralPath $file.FullName -Destination $originalPath -Force
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     # ------------------------------------------
>>"%PSFILE%" echo     # META
>>"%PSFILE%" echo     # ------------------------------------------
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     $meta = @(
>>"%PSFILE%" echo         ('SOURCE_FILE=' + $file.Name)
>>"%PSFILE%" echo         ('SOURCE_PATH=' + $file.FullName)
>>"%PSFILE%" echo         ('SOURCE_EXTENSION=' + $file.Extension)
>>"%PSFILE%" echo         ('SOURCE_SIZE_BYTES=' + $file.Length)
>>"%PSFILE%" echo         ('SOURCE_SIZE_MB=' + ('{0:N2}' -f ($file.Length / 1MB)))
>>"%PSFILE%" echo         ('OUTPUT_FOLDER=' + $number)
>>"%PSFILE%" echo     )
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     [IO.File]::WriteAllLines(
>>"%PSFILE%" echo         (Join-Path $dir 'meta.txt'),
>>"%PSFILE%" echo         $meta,
>>"%PSFILE%" echo         [Text.Encoding]::UTF8
>>"%PSFILE%" echo     )
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     # ------------------------------------------
>>"%PSFILE%" echo     # BASE64
>>"%PSFILE%" echo     # ------------------------------------------
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     Write-Host 'Creating Base64...' -ForegroundColor Yellow
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     $bytes = [IO.File]::ReadAllBytes($file.FullName)
>>"%PSFILE%" echo     $base64 = [Convert]::ToBase64String($bytes)
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     # ------------------------------------------
>>"%PSFILE%" echo     # SPLIT BASE64
>>"%PSFILE%" echo     # ------------------------------------------
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     Write-Host 'Splitting Base64...' -ForegroundColor Yellow
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     $partNumber = 1
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     for ($i = 0; $i -lt $base64.Length; $i += $chunkSize) {
>>"%PSFILE%" echo.
>>"%PSFILE%" echo         $length = [Math]::Min($chunkSize, $base64.Length - $i)
>>"%PSFILE%" echo         $part = $base64.Substring($i, $length)
>>"%PSFILE%" echo.
>>"%PSFILE%" echo         $partPath = Join-Path $dir ($partNumber.ToString() + '.txt')
>>"%PSFILE%" echo.
>>"%PSFILE%" echo         [IO.File]::WriteAllText(
>>"%PSFILE%" echo             $partPath,
>>"%PSFILE%" echo             $part,
>>"%PSFILE%" echo             [Text.Encoding]::ASCII
>>"%PSFILE%" echo         )
>>"%PSFILE%" echo.
>>"%PSFILE%" echo         $partNumber++
>>"%PSFILE%" echo     }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     $parts = $partNumber - 1
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     # ------------------------------------------
>>"%PSFILE%" echo     # SUMMARY
>>"%PSFILE%" echo     # ------------------------------------------
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     $summary = @(
>>"%PSFILE%" echo         ('SOURCE_FILE=' + $file.Name)
>>"%PSFILE%" echo         ('SOURCE_SIZE_BYTES=' + $file.Length)
>>"%PSFILE%" echo         ('BASE64_LENGTH=' + $base64.Length)
>>"%PSFILE%" echo         ('CHUNK_SIZE_BYTES=' + $chunkSize)
>>"%PSFILE%" echo         ('CHUNKS=' + $parts)
>>"%PSFILE%" echo     )
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     [IO.File]::WriteAllLines(
>>"%PSFILE%" echo         (Join-Path $dir 'summary.txt'),
>>"%PSFILE%" echo         $summary,
>>"%PSFILE%" echo         [Text.Encoding]::UTF8
>>"%PSFILE%" echo     )
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     Write-Host ('DONE: ' + $dir) -ForegroundColor Green
>>"%PSFILE%" echo     Write-Host ('PARTS: ' + $parts) -ForegroundColor Green
>>"%PSFILE%" echo.
>>"%PSFILE%" echo     $number++
>>"%PSFILE%" echo }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host '==========================================' -ForegroundColor DarkGray
>>"%PSFILE%" echo Write-Host 'ALL FILES PROCESSED!' -ForegroundColor Green
>>"%PSFILE%" echo Write-Host '==========================================' -ForegroundColor DarkGray

rem ==========================================
rem RUN POWERSHELL
rem ==========================================

echo Starting PowerShell...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"

set "EXITCODE=%ERRORLEVEL%"

rem ==========================================
rem CLEAN TEMP
rem ==========================================

del "%PSFILE%" >nul 2>&1

if not "%EXITCODE%"=="0" (
    echo.
    echo ==========================================
    echo ERROR
    echo CODE: %EXITCODE%
    echo ==========================================
    echo.
    pause
    exit /b %EXITCODE%
)

echo.
echo ==========================================
echo DONE
echo ==========================================
echo.
echo Output:
echo "%OUTPUT%"
echo.
pause