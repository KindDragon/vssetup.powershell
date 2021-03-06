@echo off

REM Copyright (C) Microsoft Corporation. All rights reserved.
REM Licensed under the MIT license. See LICENSE.txt in the project root for license information.

setlocal

if "%script%"=="" set script=%~nx0

set projectDir=%~dp0
set solutionDir=%projectDir:~0,-12%

set configuration=Debug
set name=vssetup/test

:parse
if "%1"=="" goto :parse_end
if not "%args%"=="" set args=%args% %1& shift& goto :parse
if /i "%1"=="-name" set name=%2& shift& shift& goto :parse
if /i "%1"=="/name" set name=%2& shift& shift& goto :parse
if /i "%1"=="-configuration" set configuration=%2& shift& shift& goto :parse
if /i "%1"=="/configuration" set configuration=%2& shift& shift& goto :parse
if /i "%1"=="-network" set params=%params% --network "%2"& shift& shift& goto :parse
if /i "%1"=="/network" set params=%params% --network "%2"& shift& shift& goto :parse
if /i "%1"=="-keep" set keep=1& shift& goto :parse
if /i "%1"=="/keep" set keep=1& shift& goto :parse
if "%1"=="-?" goto :help
if "%1"=="/?" goto :help
if /i "%1"=="-help" goto :help
if /i "%1"=="/help" goto :help
if "%1"=="--" set args=%2& shift& shift& goto :parse

echo.
echo Unknown argument: %1
goto :help

:parse_end
if "%keep%"=="" set params=%params% --rm

set outputPath=%solutionDir%src\VSSetup.PowerShell\bin\%configuration%
set volumes=-v "%projectDir%Instances:C:\ProgramData\Microsoft\VisualStudio\Packages\_Instances"
set volumes=%volumes% -v C:\VS\Community
set volumes=%volumes% -v C:\VS\Professional
set volumes=%volumes% -v C:\VS\Enterprise
set volumes=%volumes% -v C:\BuildTools
set volumes=%volumes% -v "%projectDir%Tests:C:\Tests"
set volumes=%volumes% -v "%outputPath%:C:\Users\ContainerAdministrator\Documents\WindowsPowerShell\Modules\VSSetup"

@echo on
docker run -it %volumes%%params% %name% %args%
@if errorlevel 1 exit /b %ERRORLEVEL%

@echo off
echo.
goto :EOF

:help
set usage=%script% [options] [-?]
if "%noargs%"=="" (
    set usage=%usage% [-- args]
)
echo.
echo %usage%
echo.
echo Options:
echo -name          Image name. Defaults to vssetup/test.
echo -configuration The build configuration to map. Defaults to Debug.
echo -network       External network name. Defaults to discovered transparent network.
echo -keep          Do not delete the container after exiting.
echo -?             Displays this help message.
echo.
if "%noargs%"=="" (
echo Arguments:
echo --             Any arguments after -- are passed to the container entry point.
echo.
)

exit /b 87
