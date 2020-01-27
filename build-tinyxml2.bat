@ECHO OFF
SETLOCAL
Setlocal EnableDelayedExpansion
REM build-tinyxml2.bat
REM *****************************************************************************
REM Author:   Charles Munson <jetwhiz@jetwhiz.com>
REM 
REM ****************************************************************************
REM Copyright (c) 2016, Charles Munson
REM 
REM This program is free software: you can redistribute it and/or modify it
REM under the terms of the GNU Lesser General Public License as published by the
REM Free Software Foundation, either version 3 of the License, or (at your
REM option) any later version.
REM 
REM This program is distributed in the hope that it will be useful, but WITHOUT
REM ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
REM FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
REM for more details.
REM 
REM You should have received a copy of the GNU Lesser General Public License
REM along with this program.  If not, see <http://www.gnu.org/licenses/>.


REM versioning variables 
set VERSION=7.1.0
set VERSION_STR=7.1.0
set SOURCE_URI=https://github.com/leethomason/tinyxml2.git



REM ========= DO NOT EDIT BELOW THIS LINE =====================



REM set up some globally-constant settings
set SRC_DIR_NAME=tinyxml2
set INSTALL_DIR=%CD%\deps\%SRC_DIR_NAME%\


REM don't bother if they already have an installation
if defined INSTALL_DIR (
  if exist "%INSTALL_DIR%\tinyxml2\Release-Lib\tinyxml2.lib" (
    if exist "%INSTALL_DIR%\tinyxml2.h" (goto :already_installed)
  )
)


REM Failed to find tinyxml2 -- ask user if they want us to build it for them
echo.
if "%INTERACTIVE%"=="1" (
    SET /P CONFIRM_BUILD="tinyxml2 was not detected.  Should we install it now? (Y/n): "
    if /I NOT "!CONFIRM_BUILD!"=="y" exit /b 1
)


REM move into deps folder 
if NOT exist "deps" mkdir deps
pushd deps


REM Clone git repository and switch to VERSION release 
echo.
echo ==================================================
echo      CLONING TINYXML2 REPOSITORY (%VERSION_STR%)
echo ==================================================
git clone %SOURCE_URI% %SRC_DIR_NAME% > %SRC_DIR_NAME%-clone.log
pushd %SRC_DIR_NAME%
git clean -ffdx
git reset --hard %VERSION%
git checkout %VERSION%

echo.
echo ~~~~~ Upgrading legacy solution ~~~~~
echo.
cmd /c devenv "tinyxml2/tinyxml2.sln" /upgrade


REM build libraries 
echo.
echo ==================================================
echo             BUILDING TINYXML2 LIBRARIES             
echo ==================================================

msbuild tinyxml2/tinyxml2.sln /p:WindowsTargetPlatformVersion=10.0.18362.0 /p:PlatformToolset=v140 /p:Configuration=Release-Lib /p:Platform=Win32 /t:Clean,Build

REM verify necessary libraries were successfully built 
if NOT exist "%INSTALL_DIR%\tinyxml2\Release-Lib\tinyxml2.lib" goto :build_failure
if NOT exist "%INSTALL_DIR%\tinyxml2.h" goto :build_failure



goto :build_success



:build_success

echo.
echo ==================================================
echo      tinyxml2 library successfully installed! 
echo ==================================================
echo.

goto :build_end



:build_failure

echo.
echo ==================================================
echo     Failed to build necessary tinyxml2 library! 
echo ==================================================
echo.
exit /b 1

goto :build_end



:already_installed

echo.
echo ==================================================
echo            tinyxml2 already installed
echo ==================================================
echo.
exit /b 0

goto :build_end



:build_end
popd
popd
exit /b 0
