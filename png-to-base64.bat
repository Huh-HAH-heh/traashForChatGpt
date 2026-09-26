
@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

rem ==========================================
rem НАСТРОЙКИ
rem ==========================================

set "ROOT=%~dp0"
set "PNG=%ROOT%resorses\s.png"
set "OUTPUT=%ROOT%path"

rem Размер одного TXT: 200 КБ
set "CHUNK_SIZE=200"

rem ==========================================
rem ПРОВЕРКА PNG
rem ==========================================

echo.
echo Проверяю PNG:
echo "%PNG%"
echo.

if not exist "%PNG%" (
    echo ERROR: PNG не найден!
    echo.
    echo Ожидаемый файл:
    echo "%PNG%"
    echo.
    echo Проверь, что структура такая:
    echo.
    echo %ROOT%
    echo +-- этот_bat.bat
    echo +-- resorses
    echo     +-- s.png
    echo.
    pause
    exit /b 1
)

echo PNG найден!

rem ==========================================
rem СОЗДАЁМ PATH
rem ==========================================

if not exist "%OUTPUT%" (
    mkdir "%OUTPUT%"
)

rem ==========================================
rem ИЩЕМ СЛЕДУЮЩИЙ НОМЕР ПАПКИ
rem ==========================================

set /a NUMBER=1

:CHECK_NUMBER

if exist "%OUTPUT%\%NUMBER%" (
    set /a NUMBER+=1
    goto CHECK_NUMBER
)

set "DIR=%OUTPUT%\%NUMBER%"

mkdir "%DIR%"

rem ==========================================
rem ИНФОРМАЦИЯ
rem ==========================================

echo.
echo ==========================================
echo PNG:
echo %PNG%
echo.
echo Результат:
echo %DIR%
echo.
echo Размер части: %CHUNK_SIZE% KB
echo ==========================================
echo.

rem ==========================================
rem ВРЕМЕННЫЙ BASE64
rem ==========================================

set "TEMP_BASE64=%TEMP%\png_base64_%RANDOM%_%RANDOM%.txt"

echo Создаю Base64...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"$png = [IO.Path]::GetFullPath('%PNG%'); ^
 $out = [IO.Path]::GetFullPath('%TEMP_BASE64%'); ^
 $bytes = [IO.File]::ReadAllBytes($png); ^
 $base64 = [Convert]::ToBase64String($bytes); ^
 [IO.File]::WriteAllText($out, $base64, [Text.Encoding]::ASCII)"

if errorlevel 1 (
    echo.
    echo ERROR: Не удалось создать Base64.
    del "%TEMP_BASE64%" >nul 2>&1
    pause
    exit /b 1
)

if not exist "%TEMP_BASE64%" (
    echo.
    echo ERROR: Base64 файл не создан.
    pause
    exit /b 1
)

echo Base64 создан.

rem ==========================================
rem РАЗБИВАЕМ BASE64
rem ==========================================

echo Разрезаю Base64 на части...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"$source = [IO.Path]::GetFullPath('%TEMP_BASE64%'); ^
 $output = [IO.Path]::GetFullPath('%DIR%'); ^
 $max = %CHUNK_SIZE% * 1024; ^
 $data = [IO.File]::ReadAllText($source); ^
 $number = 1; ^
 for ($i = 0; $i -lt $data.Length; $i += $max) { ^
     $length = [Math]::Min($max, $data.Length - $i); ^
     $part = $data.Substring($i, $length); ^
     $file = Join-Path $output ($number.ToString() + '.txt'); ^
     [IO.File]::WriteAllText($file, $part, [Text.Encoding]::ASCII); ^
     $number++; ^
 }"

if errorlevel 1 (
    echo.
    echo ERROR: Не удалось разбить Base64.
    del "%TEMP_BASE64%" >nul 2>&1
    pause
    exit /b 1
)

rem ==========================================
rem УДАЛЯЕМ ВРЕМЕННЫЙ ФАЙЛ
rem ==========================================

del "%TEMP_BASE64%" >nul 2>&1

rem ==========================================
rem РЕЗУЛЬТАТ
rem ==========================================

echo.
echo ==========================================
echo ГОТОВО!
echo ==========================================
echo.
echo PNG:
echo %PNG%
echo.
echo Папка:
echo %DIR%
echo.
echo Файлы:

dir /b "%DIR%\*.txt"

echo.
echo ==========================================

pause
