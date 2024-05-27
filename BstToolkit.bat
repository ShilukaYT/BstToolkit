@echo off
setlocal EnableDelayedExpansion EnableExtensions

mode 95,30

Set AppName=BstToolkit (Developer Test)
set ver=1.0
set vercode=1

goto :Basic

:GetPDDir
REM Get Program Data's BlueStacks Directory
set "keyPath=HKEY_LOCAL_MACHINE\SOFTWARE\%oem%"
set "valueName=UserDefinedDir"
for /f "tokens=2*" %%a in ('reg query "%keyPath%" /v "%valueName%" 2^>nul') do set "PDDir=%%b"
goto :EOF

:GetPFDir
REM Get Program Files's BlueStacks Directory
set "PFDir=%ProgramFiles%\%oem%"
goto :EOF

:GetUnlockStatus

REM Get system file info to decide

"%ProgramFiles%\BlueStacks_nxt\BstkVMMgr.exe" showmediuminfo "%ProgramData%\BlueStacks_nxt\Engine\Nougat32\Root.vhd" > "%~dp0Temp\temp.txt"

for /f "tokens=2 delims=:" %%a in ('type "%~dp0Temp\temp.txt" ^| findstr /C:"Type"') do (
    set "typeValue=%%a"
    set "typeValue=!typeValue: (base)=!"
)

for /f "tokens=* delims= " %%a in ("!typeValue!") do set "typeValue=%%a"

del %~dp0Temp\temp.txt

:: Sử dụng biến typeValue

if %typeValue%==readonly (
  set "Unlock=0"
)

if %typeValue%==normal (
  set "Unlock=1"
)

goto :EOF

:GetVersion
set "keyPath=HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks_nxt"
set "valueName=Version"
for /f "tokens=2*" %%a in ('reg query "%keyPath%" /v "%valueName%" 2^>nul') do set "Version=%%b"
for /f "tokens=2 delims=." %%a in ("%Version%") do (
    set "VerNumber=%%a"
)
goto :EOF

:Basic
title %AppName%
cd /d %~dp0


set BIN=%~dp0bin

set "AndroidTool=%BIN%\platform-tools"
set "adb=%AndroidTool%\adb.exe"
set "pwshfolder=%BIN%\PowerShell"
set "pwsh=%pwshfolder%\pwsh.exe"

set "RootPatchFile=%~dp0Root"
set "MagiskFile=%RootPatchFile%\Magisk"
set "SuperSUFile=%RootPatchFile%\SuperSU"
Set "Magisk_Kitsune_Stable=%RootPatchFile%\KitsuneMagisk_Stable.apk"
set "Magisk_Kitsune_Canary=%RootPatchFile%\KitsuneMagisk_Canary.apk"

set "Line================================================================================================"

if not exist "%~dp0Temp" (
  mkdir "%~dp0Temp"
)

::Check administrator
goto :SelEmu



::Language: English



:CreUI
:: Create UI
echo %Line%
echo                                         BstToolkit
echo                                    Made by Hieu GL Lite
echo %line%
echo.
goto :EOF

:SelEmu
:: Select Emulator
cls
title %AppName%
set "goafter=:SelEmu"
call :CreUI
Echo   Please select an emulator to continue!
echo.
echo   [1] BlueStacks 5 (Version 5.20+) (Active)
echo   [2] BlueStacks 5 (Comming soon)
echo   [3] BlueStacks 4 (Comming soon)
echo   [4] MSI App Player 5 (Comming soon)
echo   [5] MSI App Player 4 (Comming soon)
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo %line%
echo [Z] Subscribe to Hieu GL Lite
echo [X] Quit
echo %line%
choice /c:12345ZX /n /m "Enter your choice: "
if errorlevel 7 goto :Quit
if errorlevel 6 goto :Youtube
if errorlevel 5 goto :Unavailable
if errorlevel 4 goto :Unavailable
if errorlevel 3 goto :Unavailable
if errorlevel 2 goto :Unavailable
if errorlevel 1 goto :BS5_ulk

:BS5_ulk

set "EmuName=BlueStacks 5"
Set "oem=BlueStacks_nxt"

call :GetPDDir
call :GetPFDir
call :GetVersion

if exist %VerNumber% GEQ 20 (
  goto :SelOS
) else (
  goto :BS_ulk_req
)

::Select OS of Emulator
:SelOS
cls
title %AppName%
set "goafter=:SelOS"
call :CreUI
echo   Selected emulator: %EmuName%
echo   Emulator version: %Version%
echo   Program Data directory: %PDDir%
echo   Program Files directory: %PFDir%
echo.
echo %line%
echo.
echo   Please select the operating system you have installed!
echo.
echo   [1] Android 7 32-bit (Nougat32)
echo   [2] Android 7 64-bit (Nougat64) (Not supported yet)
echo   [3] Android 9 64-bit (Pie64)
echo   [4] Android 11 64-bit (Rvc64) (Not supported yet)
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo %line%
echo [X] Return
echo %line%
choice /c:1234X /n /m "Enter your choice: "
if errorlevel 5 goto :SelEmu
if errorlevel 4 goto :Unavailable
if errorlevel 3 goto :Unavailable
if errorlevel 2 goto :Unavailable
if errorlevel 1 goto :Nougat32

:Nougat32
set "OS=Nougat32"
set "OSName=Android 7 32-bit"
goto :ToolkitMenu



:ToolkitMenu
set "goafter=:ToolkitMenu"
cls
call :CreUI
echo   Selected emulator: %EmuName%
echo   Emulator version: %Version%
echo   Program Data directory: %PDDir%
echo   Program Files directory: %PFDir%
echo   Selected operating system: %OSName%
echo   Operating system path: %PDDir%\Engine\%OS%
echo.
echo %line%
echo.
echo   Please choose the tool you want!
echo.
echo   [1] Unlock/Lock %EmuName%
echo   [2] Enable root access
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo %line%
echo [X] Return
echo %line%
choice /c:12X /n /m "Enter your choice: "
if errorlevel 3 goto :SelOS
if errorlevel 2 goto :Quit
if errorlevel 1 goto :UnlockMenu

::Unlock Menu
:UnlockMenu
cls
call :CreUI
::Check Unlock Status
echo Retrieving information...
call :GetUnlockStatus

if %Unlock%==1 (
  goto :LockBackup
)
if %Unlock%==0 (
  goto :UnlockBackup
)



:UnlockBackup
pause
cls
call :CreUI
echo   Selected emulator: %EmuName%
echo   Emulator version: %Version%
echo   Program Data directory: %PDDir%
echo   Program Files directory: %PFDir%
echo   Selected operating system: %OSName%
echo   Operating system path: %PDDir%\Engine\%OS%
echo.
echo %line%
echo.
echo   Do you want to back up system files?
echo.
echo   [1] Yes (Recommend)
echo   [2] No
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo %line%
echo [X] Return
echo %line%
choice /c:12X /n /m "Enter your choice: "
if errorlevel 3 goto :ToolkitMenu
if errorlevel 2 (
  set "backup=-no-backup"
  set "SetRW=Unlock"
)
if errorlevel 1 (
  set "backup=-backup"
  set "SetRW=Unlock"
)

:LockBackup
cls
call :CreUI
echo   Selected emulator: %EmuName%
echo   Emulator version: %Version%
echo   Program Data directory: %PDDir%
echo   Program Files directory: %PFDir%
echo   Selected operating system: %OSName%
echo   Operating system path: %PDDir%\Engine\%OS%
echo.
echo %line%
echo.
echo   Do you want to restore system files?
echo   If you select yes, any changes you make to system files will revert to their original state
echo.
echo   [1] Yes
echo   [2] No
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo %line%
echo [X] Return
echo %line%
choice /c:12X /n /m "Enter your choice: "
if errorlevel 3 goto :ToolkitMenu
if errorlevel 2 (
  set "backup=-no-backup"
  set "SetRW=Lock"
)
if errorlevel 1 (
  set "backup=-backup"
  set "SetRW=Lock"
)

:



:Unavailable
cls
call :CreUI
echo This feature is not currently available, please wait for the next update!
timeout 5 /nobreak >nul
goto %goafter%

:BS_ulk_req
cls
call :CreUI
echo Please install/update to version 5.20 or higher to continue!
timeout 5 /nobreak >nul
goto %goafter%

:Youtube
cls
Title %AppName% - Redirecting
call :CreUI
Echo Redirecting to Youtube
start https://www.youtube.com/@HieuGLLite?sub_confirmation=1
timeout 5 /nobreak >nul
goto :SelEmu

:Quit
cls
call :CreUI
echo Thank you for choosing me!!!
echo :3
echo.
echo Shutting down...
timeout 5 /nobreak >nul
rmdir /s /q "%~dp0Temp"
endlocal
Exit /b
