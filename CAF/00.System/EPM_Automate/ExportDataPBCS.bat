@ECHO OFF

REM ---------------------------------------------------------
REM The Hackett Group
REM Author: rjimenez
REM Date: Jul 2016
REM ExportDataPBCS.bat 
REM ---------------------------------------------------------

SETLOCAL ENABLEDELAYEDEXPANSION

SET readConfig=%cd%\00.System\Batch\readConfig.bat
IF "%2"=="" ( SET inifile=%cd%\Config.ini ) ELSE ( SET inifile=%cd%\%2 )

CALL %readConfig% %inifile% Global
CALL %readConfig% %inifile% %1

ECHO.
ECHO ---------------------------------------------------------
ECHO %DATE% - %TIME% Start of process
ECHO ---------------------------------------------------------
ECHO.

ECHO.> %log_file%
ECHO --------------------------------------------------------- >> %log_file%
ECHO %DATE% - %TIME% Start of process >> %log_file%
ECHO --------------------------------------------------------- >> %log_file%
ECHO.>> %log_file%

ECHO PBCS url         : %url% >> %log_file%
ECHO Log file         : %log_file% >> %log_file%
ECHO Outbox folder    : %download_dir% >> %log_file%
ECHO.>> %log_file%

ECHO PBCS url         : %url%
ECHO Log file         : %log_file%
ECHO Outbox folder   : %download_dir%
ECHO.

SET message="%date% %time% - Login"
ECHO ---------------------------------------------------------
ECHO %message:"=%
ECHO ---------------------------------------------------------
ECHO --------------------------------------------------------- >> %log_file%
ECHO %message:"=% >> %log_file%
ECHO --------------------------------------------------------- >> %log_file%
CALL %epmautomate_client% login %user% %password% %url% %domain% >> %log_file%
IF %ERRORLEVEL% NEQ 0 ( 
CALL :ErrorPara %message% %log_file% 
EXIT )
ECHO.
ECHO.>> %log_file%


SET message="%date% %time% - Export Data"
ECHO %message:"=%
ECHO %message:"=% >> %log_file%
CALL %epmautomate_client% exportdata %jobname% %filename% >> %log_file%
IF %ERRORLEVEL% NEQ 0 ( 
CALL :ErrorPara %message% %log_file% 
)
ECHO.
ECHO.>> %log_file%


SET message="%date% %time% - Download File %filename%"
ECHO %message:"=%
ECHO %message:"=% >> %log_file%
CALL %epmautomate_client% downloadfile %filename% >> %log_file%
IF %ERRORLEVEL% NEQ 0 ( 
CALL :ErrorPara %message% %log_file% 
EXIT )
ECHO.
ECHO.>> %log_file%


SET message="%date% %time% - Move file %filename% to %targetdir%"
ECHO %message:"=%
ECHO %message:"=% >> %log_file%
MOVE %download_dir%\%filename% %targetdir% >> %log_file%
IF %ERRORLEVEL% NEQ 0 ( 
CALL :ErrorPara %message% %log_file% 
EXIT )
ECHO.
ECHO.>> %log_file%


SET message="%date% %time% - Logout"
ECHO ---------------------------------------------------------
ECHO %message:"=%
ECHO ---------------------------------------------------------
ECHO --------------------------------------------------------- >> %log_file%
ECHO %message:"=% >> %log_file%
ECHO --------------------------------------------------------- >> %log_file%
CALL %epmautomate_client% logout >> %log_file%
IF %ERRORLEVEL% NEQ 0 ( 
CALL :ErrorPara %message% %log_file% 
EXIT )
ECHO.
ECHO.>> %log_file%

ECHO --------------------------------------------------------- >> %log_file%
ECHO %DATE% - %TIME% End of process>> %log_file%
ECHO --------------------------------------------------------- >> %log_file%

ECHO ---------------------------------------------------------
ECHO %DATE% - %TIME% End of process
ECHO ---------------------------------------------------------

PAUSE
EXIT

:ErrorPara 
ECHO.
ECHO ---------------------------------------------------------
ECHO Step Failed : %~1 with ErrorCode# %ERRORLEVEL%
ECHO Logging Out. Go to %url% for details.
ECHO 
ECHO ---------------------------------------------------------
ECHO.
ECHO. >> %~2
ECHO --------------------------------------------------------- >> %~2
ECHO Step Failed : %~1 with ErrorCode# %ERRORLEVEL% >> %~2
ECHO Logging Out. Go to %url% for details. >> %~2
ECHO --------------------------------------------------------- >> %~2
ECHO. >> %~2

powershell %batch_dir%\sendEmail.ps1 -email %email% -attachment %log_file% -jobname %jobname% -url %url%

EXIT
