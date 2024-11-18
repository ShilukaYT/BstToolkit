::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAnk
::fBw5plQjdG8=
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSDk=
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
::Zh4grVQjdCyDJGyX8VAjFDpQQQ2MAE+1BaAR7ebv/Nagq1k1QeADWpzP7ruBLOsa/nnGZoIZ2XVWk8IYMw1ZbFyudgpU
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off

setlocal

if "%~1"=="" goto :EOF
if %1==GetVar_Blue5 goto :BS5_var
if %1==GetVar_Blue4 goto :BS4_var
if %1==GetVar_MSI4 goto :MSI4_var
if %1==GetVar_MSI5 goto :MSI5_var
if %1==GetVar_Basic goto :Basic

goto :EOF

:BS5_var
set "keyPath=HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks_nxt"
set "valueName=InstallDir"
for /f "tokens=2*" %%a in ('reg query "%keyPath%" /v "%valueName%" 2^>nul') do set "BS5_PDDir=%%b"
goto :EOF

:BS4_var
set "keyPath=HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks"
set "valueName=InstallDir"
for /f "tokens=2*" %%a in ('reg query "%keyPath%" /v "%valueName%" 2^>nul') do set "BS4_PDDir=%%b"
goto :EOF

:MSI4_var
set "keyPath=HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks_msi2"
set "valueName=InstallDir"
for /f "tokens=2*" %%a in ('reg query "%keyPath%" /v "%valueName%" 2^>nul') do set "MSI4_PDDir=%%b"
goto :EOF

:MSI5_var
set "keyPath=HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks_msi5"
set "valueName=InstallDir"
for /f "tokens=2*" %%a in ('reg query "%keyPath%" /v "%valueName%" 2^>nul') do set "MSI5_PDDir=%%b"
goto :EOF


:Basic
set "BS5_PFDir=%ProgramFiles%\BlueStacks_nxt"
set "BS4_PFDir=%ProgramFiles%\BlueStacks"
set "MSI4_PFDir=%ProgramFiles%\BlueStacks_msi2"
set "MSI5_PFDir=%ProgramFiles%\BlueStacks_msi5"

set "adb=%~dp0platform-tools"

set "RootPatchFile=%~dp0Root"
set "MagiskFile=%RootPatchFile%\Magisk"
set "SuperSUFile=%RootPatchFile%\SuperSU"
Set "Magisk_Kitsune_Stable=%RootPatchFile%\KitsuneMagisk_Stable.apk"
set "Magisk_Kitsune_Canary=%RootPatchFile%\KitsuneMagisk_Canary.apk"

:EOF
endlocal