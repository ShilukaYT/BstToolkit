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

:Prepare
Set PFDir=%1
Set PDDir=%2
Set OS=%3
Set VDF=%4
Set UnlockOpt=%5
set BackupOpt=%6

echo.
echo %AppName%
echo %ver%
echo.

if %UnlockOpt%==-Unlock (
    set "Status=1"
)
if %UnlockOpt%==-Lock (
    set "Status=0"
)


:UnlockPreparre

if %BackupOpt%==-backup (
    set "Backup=1"
)
if %BackupOpt%==-no-backup (
    set "Backup=0"
)

if %Backup%==1 (
    echo Copying system file...
    copy "%PDDir%\Engine\%OS%\Root.%VDF%" %PDDir%\Engine\%OS%\Root_original.%VDF%
    goto :UnlockEmu
)

if %Backup%==0 (
    goto :UnlockEmu
)

:UnlockEmu
echo Unlocking...
"%PFDir%\BstkVMMgr.exe" modifyhd "%PDDir%\Engine\%OS%\Root.%VDF%" --type normal


:Quit