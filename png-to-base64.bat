```text
@echo off
setlocal EnableDelayedExpansion

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

if not exist "%PNG%" (
    echo.
    echo ERROR: PNG не найден:
    echo "%PNG%"
    echo.
    pause
    exit /b 1
)

rem ==========================================
rem СОЗДАЁМ PATH
rem ==========================================

if not exist "%OUTPUT%" (
    mkdir "%OUTPUT%"
)

rem ==========================================
rem ИЩЕМ СЛЕДУЮЩИЙ НОМЕР
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

set "TEMP_BASE64=%TEMP%\rimclone_base64_%RANDOM%_%RANDOM%.txt"

echo Создаю Base64...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$png='%PNG%'; $out='%TEMP_BASE64%'; $base64=[Convert]::ToBase64String([IO.File]::ReadAllBytes($png)); [IO.File]::WriteAllText($out,$base64,[Text.Encoding]::ASCII)"

if not exist "%TEMP_BASE64%" (
    echo.
    echo ERROR: Base64 файл не создан.
    echo.
    pause
    exit /b 1
)

rem ==========================================
rem РАЗБИВАЕМ BASE64
rem ==========================================

echo Разрезаю на части...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$source='%TEMP_BASE64%'; $output='%DIR%'; $max=200*1024; $data=[IO.File]::ReadAllText($source); $number=1; for($i=0; $i -lt $data.Length; $i += $max){$length=[Math]::Min($max,$data.Length-$i); $part=$data.Substring($i,$length); [IO.File]::WriteAllText((Join-Path $output ($number.ToString()+'.txt')),$part,[Text.Encoding]::ASCII); $number++}"

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
echo Папка:
echo %DIR%
echo.
echo Файлы:

dir /b "%DIR%\*.txt"

echo.
echo ==========================================

pause
```
