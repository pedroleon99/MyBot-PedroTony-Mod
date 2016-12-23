@echo off
Setlocal EnableDelayedExpansion
set "version=push_Roboto-Regular.bat v1.3"

:: 2016-08-08 cosote Changed ADB order to reflect upcoming MyBot.run 6.2.2 release
:: 2016-05-02 cosote Changed ADB order to reflect upcoming MyBot.run 5.3.3/6.0 release

echo:
echo  !version! Tool by MyBot.run
echo  =============================================================================
echo  Push Roboto-Regular.ttf font to all connected rooted Android devices.
echo  This fixes MyBot.run Android system message detection for MEmu, Nox, Droid4X.
echo  Close any Android that should not get this Roboto-Regular.ttf file pushed.
echo  Please stop any MyBot.run and reboot all Android emulators after install.
echo  =============================================================================
echo:
pause
set "programfolder="
set adb=""
if exist "adb.exe" (
	set "programfolder=.\"
	set adb="!programfolder!adb.exe"
)
if "!programfolder!" equ "" (
	call :log Checking MEmu installation path...
	:: Environment variable might not be refreshed/available when MEmu was just installed :( rebooting Windows does fix that...
	if exist "%MEmu_Path%\MEmu\adb.exe" (
		set "programfolder=%MEmu_Path%\MEmu\"
	)
	:: Ok, also check default location... probably sitting there...
	if !programfolder! equ "" (
		if exist "%ProgramFiles%\Microvirt\MEmu\adb.exe" set "programfolder=%ProgramFiles%\Microvirt\MEmu\"
		if exist "%ProgramFiles(x86)%\Microvirt\MEmu\adb.exe" set "programfolder=%ProgramFiles(x86)%\Microvirt\MEmu\"
	)
	if exist "!ProgramFolder!adb.exe" set adb="!ProgramFolder!adb.exe"
)
:: Now check LeapDroid adb.exe
if "!programfolder!" equ "" (
	call :log Checking BlueStacks installation path...
	if exist "%ProgramFiles%\Leapdroid\VM\adb.exe" set "programfolder=%ProgramFiles%\Leapdroid\VM\"
	if exist "%ProgramFiles(x86)%\BlueStacks\HD-Adb.exe" set "programfolder=%ProgramFiles(x86)%\Leapdroid\VM\"
	if exist "!ProgramFolder!adb.exe" set adb="!ProgramFolder!adb.exe"
)
:: Now check BlueStacks HD-Adb.exe
if "!programfolder!" equ "" (
	call :log Checking BlueStacks installation path...
	if exist "%ProgramFiles%\BlueStacks\HD-Adb.exe" set "programfolder=%ProgramFiles%\BlueStacks\"
	if exist "%ProgramFiles(x86)%\BlueStacks\HD-Adb.exe" set "programfolder=%ProgramFiles(x86)%\BlueStacks\"
	if exist "!ProgramFolder!HD-Adb.exe" set adb="!ProgramFolder!HD-Adb.exe"
)
:: Now check if Droid4X is installed and adb.exe available there
if "!programfolder!" equ "" (
	call :log Checking Droid4X installation path...
	if exist "%windir%\sysWOW64" (
		set AndroidReg="HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Droid4X"
	) else (
		set AndroidReg="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Droid4X"
	)
	for /f "tokens=2,*" %%i in ('"reg query !AndroidReg! /v DisplayIcon 2>nul|findstr /i "DisplayIcon" 2>nul"') do (
		if exist "%%~dpjadb.exe" set "programfolder=%%~dpj"
	)
	if "!programfolder!" equ "" (
		rem if exist "%ProgramFiles%\Droid4X\adb.exe" set "programfolder=%ProgramFiles%\Droid4X\"
		rem if exist "%ProgramFiles(x86)%\Droid4X\adb.exe" set "programfolder=%ProgramFiles(x86)%\Droid4X\"
	)
	if exist "!ProgramFolder!adb.exe" set adb="!ProgramFolder!adb.exe"
)
:: Now check if Nox is installed and nox_adb.exe available there
if "!programfolder!" equ "" (
	call :log Checking Nox installation path...
	if exist "%windir%\sysWOW64" (
		set "AndroidReg=HKLM\SOFTWARE\Wow6432Node\DuoDianOnline\SetupInfo"
	) else (
		set "AndroidReg=HKLM\SOFTWARE\DuoDianOnline\SetupInfo"
	)
	for /f "tokens=2,*" %%i in ('"reg query !AndroidReg! /v InstallPath 2>nul|findstr /i "InstallPath" 2>nul"') do (
		if exist "%%~j\bin\nox_adb.exe" set "programfolder=%%~j\bin\"
	)
	if "!programfolder!" equ "" (
		if exist "%ProgramFiles%\Nox\bin\nox_adb.exe" set "programfolder=%ProgramFiles%\Nox\bin\"
		if exist "%ProgramFiles(x86)%\Nox\bin\nox_adb.exe" set "programfolder=%ProgramFiles(x86)%\Nox\bin\"
	)
	if exist "!ProgramFolder!nox_adb.exe" set adb="!ProgramFolder!nox_adb.exe"
)
rem :: custom path required?... there you go ;)
rem :: if exist "D:\Program Files\Microvirt\MEmu\adb.exe" set adb="D:\Program Files\Microvirt\MEmu\adb.exe"
if not exist !adb! goto :missing

echo:
echo  Using: !adb!

for /f %%a in ('!adb! devices') do (
	set "adb_device=%%a"
	if "!adb_device!" EQU "adb" set "adb_device="
	if "!adb_device!" EQU "*" set "adb_device="
	if "!adb_device!" EQU "List" set "adb_device="
	if "!adb_device!" NEQ "" (
		echo:
		echo  =============================================================================
		echo  Push Roboto-Regular.ttf to %%a...
		echo  =============================================================================
		:: mount -o rw,remount /system
		!adb! -s %%a remount
		!adb! -s %%a push Roboto-Regular.ttf /system/fonts
	)
)
echo:
echo  =============================================================================
echo  Done.
echo  =============================================================================
echo:
echo  Hope all when well and you see above something like this for each Emulator:
echo remount succeeded
echo 904 KB/s (114976 bytes in 0.124s)
echo:
pause
goto :end

:log text
echo %*
exit /b

:missing
echo:
echo  Couldn't find MEmu/Droid4X adb.exe... please review this batch file... or:
echo  If you just installed MEmu, you need to reboot your computer.
echo  Then launch this script again...
echo:
pause

:end