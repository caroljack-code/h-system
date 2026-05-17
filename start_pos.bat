@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo Checking dependencies...
python -m pip install -r backend/requirements.txt

if "%POS_PORT%"=="" set POS_PORT=5000
:: Default to 0.0.0.0 to allow access from other devices on the network
if "%POS_BIND_HOST%"=="" set POS_BIND_HOST=0.0.0.0

:: Get local IP address
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4 Address"') do (
    set IP=%%a
    set IP=!IP: ^=!
    goto :found_ip
)
:found_ip

echo.
echo ======================================================
echo   PIMUT TRADERS POS IS STARTING
echo ======================================================
echo.
echo  Local Access:    http://127.0.0.1:%POS_PORT%/
if not "!IP!"=="" (
    echo  Network Access:  http://!IP!:%POS_PORT%/
    echo.
    echo  To use on other devices, open the Network Access URL
    echo  in their web browsers.
)
echo.
echo ======================================================

start "POS Backend" powershell -NoProfile -Command " $env:POS_BIND_HOST='%POS_BIND_HOST%'; $env:POS_PORT='%POS_PORT%'; python backend/app.py "

:: Wait for server to start
powershell -NoProfile -Command " try{ $port=$env:POS_PORT; if(-not $port){$port=5000}; $max=30; $i=0; while($i -lt $max){ $ok = (Test-NetConnection -ComputerName 127.0.0.1 -Port $port).TcpTestSucceeded; if($ok){ break } ; Start-Sleep -Seconds 1; $i++ } }catch{} "

start "" http://127.0.0.1:%POS_PORT%/
exit /b
