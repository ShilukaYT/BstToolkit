::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAjk
::fBw5plQjdCqDJHWL801wI7ieQgy+LmSvCLEZ7KXy4aeXqkIJW/A6bJ3S2bXAKeMcig==
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSjk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFDpwYS2sAE+1BaAR7ebv/Nagq1k1QeADWpzP7ruBLOsa/nnmfJgR43RWl8gHJB5Ubhe5IAosrA4=
::YB416Ek+ZW8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off

setlocal EnableDelayedExpansion EnableExtensions

Set AppName=BstToolkit - Unlock/Lock Helper
set ver=1.0
set vercode=1

if "%~1"=="" (
    goto :Quit
) else (
    goto :Prepare
)

:GetPDDir
REM Get Program Data's BlueStacks Directory
set "keyPath=HKEY_LOCAL_MACHINE\SOFTWARE\%oem%"
set "valueName=UserDefinedDir"
for /f "tokens=2*" %%a in ('reg query "%keyPath%" /v "%valueName%" 2^>nul') do set "PDDir=%%b"
goto :EOF

:GetPFDir
REM Get Program Files's BlueStacks Directory
set "PFDir=""%ProgramFiles%"\%oem%""
goto :EOF

:GetVersion
set "keyPath=HKEY_LOCAL_MACHINE\SOFTWARE\%oem%"
set "valueName=Version"
for /f "tokens=2*" %%a in ('reg query "%keyPath%" /v "%valueName%" 2^>nul') do set "Version=%%b"
for /f "tokens=2 delims=." %%a in ("%Version%") do (
    set "VerNumber=%%a"
)
if %VerNumber% GEQ 3 (
    set VDF=VHD
    set VDFile=vhd
)
if %VerNumber% LEQ 2 (
    set VDF=VDI
    set VDFile=vdi
)
goto :EOF

:Prepare
Set oem=%1
Set OS=%2
Set UnlockOpt=%3
set BackupOpt=%4

call :GetPDDir
call :GetPFDir
call :GetVersion


set "BSTK_FILE="%PDDir%\Engine\%OS%\%OS%.bstk""
set "BSTK_BAK_FILE="%PDDir%\Engine\%OS%\%OS%.bstk-prev""

echo.
echo %AppName%
echo %ver%
echo.



if %UnlockOpt%==-Unlock (
    goto :UnlockPrepare
)
if %UnlockOpt%==-Lock (
    goto :LockPrepare
)

:UnlockPrepare
if %BackupOpt%==--backup (
    echo Copying system file...
    copy "%PDDir%\Engine\%OS%\Root.%VDFile%" "%PDDir%\Engine\%OS%\Root_original.%VDFile%"
    echo.
    goto :UnlockEmu
)

if %BackupOpt%==--no-backup (
    goto :UnlockEmu
)

:UnlockEmu
echo Unlocking...
"%PFDir%\BstkVMMgr.exe" modifyhd "%PDDir%\Engine\%OS%\Root.%VDFile%" --type normal

goto :Quit

:LockPrepare
if %BackupOpt%==--backup (
    echo Restoring system files...
    del /s /q "%PDDir%\Engine\%OS%\Root.%VDFile%"
    move "%PDDir%\Engine\%OS%\Root_original.%VDFile%" "%PDDir%\Engine\%OS%\Root.%VDFile%"
    echo.
    goto :LockEmu
)

if %BackupOpt%==--no-backup (
    echo Deleting backup file...
    del /s /q "%PDDir%\Engine\%OS%\Root_original.%VDFile%"
    echo.
    goto :LockEmu
)

:LockEmu
echo Locking...
del /s /q %BSTK_BAK_FILE%
set "Search=<HardDisk uuid="{fca296ce-8268-4ed7-a57f-d32ec11ab304}" location="Root.%VDFile%" format="%VDF%" type="Normal""
set "replace=<HardDisk uuid="{fca296ce-8268-4ed7-a57f-d32ec11ab304}" location="Root.%VDFile%" format="%VDF%" type="Readonly""
powershell -Command "(Get-Content '%BSTK_FILE%') -replace '%search%', '%replace%' | Set-Content '%BSTK_FILE%'"

:Quit