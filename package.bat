@ECHO OFF
REM build.bat
REM *****************************************************************************
REM Author:   Charles Munson <jetwhiz@jetwhiz.com>
REM 
REM ****************************************************************************
REM Copyright (c) 2019, Charles Munson
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


REM Up front environment variables 
set PROJECT_DIR=%CD%
set DEP_DIR="%PROJECT_DIR%\..\encfs-bin\"
set PRODUCT_VERSION="1.10.2"
set DOKAN_VERSION="1.3.1.1000"



REM Make sure nsis is installed 
echo Looking for NSIS installation ...
where /q makensis || goto :no_nsis
echo.



REM Make sure dependencies exist
echo.
echo Checking encfs binaries ...

echo Looking for encfs\win\dialog-password.ico ...
if NOT exist "%PROJECT_DIR%\encfs\win\dialog-password.ico" goto :no_deps

echo Looking for encfs\Release\encfs.exe ...
if NOT exist "%PROJECT_DIR%\encfs\Release\encfs.exe" goto :no_deps

echo Looking for encfs\Release\encfsctl.exe ...
if NOT exist "%PROJECT_DIR%\encfs\Release\encfsctl.exe" goto :no_deps

echo Looking for encfs\Release\encfsw.exe ...
if NOT exist "%PROJECT_DIR%\encfs\Release\encfsw.exe" goto :no_deps


echo.
echo Checking openssl binaries in '%OPENSSL_ROOT%' ...

echo Looking for libeay32.dll ...
if NOT exist "%OPENSSL_ROOT%\bin\libeay32.dll" goto :no_deps

echo Looking for ssleay32.dll ...
if NOT exist "%OPENSSL_ROOT%\bin\ssleay32.dll" goto :no_deps


echo.
echo Checking dependencies folder '%DEP_DIR%'

echo Looking for encfs4win.ico ...
if NOT exist "%DEP_DIR%\encfs4win.ico" goto :no_deps

echo Looking for DokanSetup_redist-%DOKAN_VERSION%.exe
if NOT exist "%DEP_DIR%\DokanSetup_redist-%DOKAN_VERSION%.exe" goto :no_deps



REM Package encfs 
echo.
echo ==================================================
echo              BUILDING ENCFS INSTALLER
echo ==================================================
if exist "%DEP_DIR%\encfs-installer.exe" del "%DEP_DIR%\encfs-installer.exe"
makensis /V3 /DDOKAN_VERSION="%DOKAN_VERSION%" /DPRODUCT_VERSION="%PRODUCT_VERSION%" "%PROJECT_DIR%\encfs\encfs-installer.nsi"

REM verify necessary executables were successfully built  
if NOT exist "%DEP_DIR%\encfs-installer.exe" goto :pkg_failure


echo.
echo ==================================================
echo                PACKAGING ENCFS ZIP
echo ==================================================
where /q 7z
IF ERRORLEVEL 1 (
	echo Cannot find 7z, skipping zip creation
) ELSE (
	if exist "%DEP_DIR%\encfs-nodeps.zip" del "%DEP_DIR%\encfs-nodeps.zip"
	7z a -aos "%DEP_DIR%\encfs-nodeps.zip"^
			"%PROJECT_DIR%\encfs\win\dialog-password.ico"^
			"%PROJECT_DIR%\encfs\Release\encfs.exe"^
			"%PROJECT_DIR%\encfs\Release\encfsctl.exe"^
			"%PROJECT_DIR%\encfs\Release\encfsw.exe"^
			"%OPENSSL_ROOT%\bin\libeay32.dll"^
			"%OPENSSL_ROOT%\bin\ssleay32.dll"

	REM verify necessary executables were successfully built  
	if NOT exist "%DEP_DIR%\encfs-nodeps.zip" goto :pkg_failure
)

goto :pkg_success



:pkg_success

echo.
echo ==================================================
echo           Encfs successfully packaged!
echo ==================================================
echo.

goto :end



:pkg_failure

echo.
echo ==================================================
echo               Failed to package Encfs!
echo ==================================================
echo.
exit /b 1

goto :end



:no_deps

echo.
echo ==================================================
echo     Could not find needed dependencies!
echo ==================================================
echo.
exit /b 1

goto :end



:no_nsis

echo.
echo ==================================================
echo     NSIS is required to package this project!
echo ==================================================
echo.
exit /b 1

goto :end



:end
exit /b 0
