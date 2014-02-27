@ECHO OFF

:: COMMAND LINE ARGS
:: Run as 'make.bat test' to build and copy to Arma 3 dir
:: Run as 'make.bat release 0.2beta' to make a release zip file

:: BUILD SETTINGS
set releaseFolder=@tao_foldmap_a3
set modules=tao_foldmap_a3
set workPath=P:\
set BinPBO="F:\Games\Steam\steamapps\common\Arma 3 Tools\AddonBuilder.exe"
set Zip="C:\Program Files\7-Zip\7z.exe"
set Arma3Dir="C:\Games\Arma 3"


::::::::::::::::::::::::::::

set releaseDir=%CD%\release\%releaseFolder%\Addons\

::::::::::::::::::::::::::::

mkdir %releaseDir%

FOR %%A IN (%modules%) DO (
	set currentModule=%%A
	CALL :Build
)

CALL :Cleanup

IF "%1"=="release" CALL :Release
IF "%1"=="test" CALL :Test

GOTO :End

::::::::::::::::::::::::::::

:: Sub to build a module
:Build
ECHO ###############################
ECHO Building %currentModule%...
ECHO ###############################

ECHO Copying files to %workPath% ...
rmdir %workPath%%currentModule% /S /Q 
robocopy %currentModule% %workPath%%currentModule% /E /njh /njs /ndl /nc /ns /NFL

ECHO BinPBOing %currentModule%...
ECHO -------------------------------
%BinPBO% %workPath%%currentModule% %releaseDir%
ECHO -------------------------------
ECHO:
ECHO Build of %currentModule% complete!
ECHO:
ECHO:

GOTO :EOF

:: Sub to make release
:Release
ECHO Zipping up release...
del @tmr-%2.zip
%Zip% a @tmr-%2.zip .\release\*
GOTO :EOF

:: Sub to copy the build to your Arma 3 folder
:Test
ECHO Copying current build to Arma 3...
robocopy release\@tmr %Arma3Dir%\%releaseFolder% /E /njh /njs /ndl /nc /ns /nfl
GOTO :EOF

:: Sub to cleanup log files
:Cleanup
ECHO All builds complete, cleaning up...
del %releaseDir%*.log
GOTO :EOF

:End
PAUSE