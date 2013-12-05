@echo off

::--------------------------------------------------------
::-- Execution Arguments - These will be passed via the calling script
::--------------------------------------------------------
IF [%1]==[--help] goto:printHelp

:: The URL that the CQ server will answer on.  do not add a trailing slash!
IF [%1]==[] goto:printHelp
set "SERVER_URL=%1" 

:: The credentials used to access CQ (in format username:password).   This should not be an admin user.
IF [%2]==[] goto:printHelp
set "SERVER_CREDENTIALS=%2"

:: The folder that will be used within the CQ repository.  This folder must already exist in CQ.  Do not add a trailing slash!  
IF [%3]==[] goto:printHelp
set "SERVER_FOLDER_PATH=%3"

:: the identifier that will be used for all these imports
IF [%4]==[] goto:printHelp
set "ARTICLE_NAME=%4"

:: This is the assigned editor of the manuscripts, this should be an existing user in CQ
IF [%5]==[] goto:printHelp
set "MANUSCRIPT_EDITOR=%5"

:: the local folder that contains the folder containing the mutliple text files wanting to be imported
IF [%6]==[] goto:printHelp
set "LOCAL_FILE_DIR=%6"


::--------------------------------------------------------
::-- Server Arguments - these should be set once, per server the script is put on
::--------------------------------------------------------
:: path to the curl.exe
set "CURL=C:\Users\dcollie\Tools\Bin\curl.exe"


::--------------------------------------------------------
::-- Main method
::--------------------------------------------------------
set "LOG_FILE=output-%date:~-4%%date:~-3%%date:~-2%%time:~0,2%%time:~3,2%%time:~6,2%.log"

call:logEntry %LOG_FILE% "STARTING Manuscript Creation"

set folderURL=[UNSET]
call:createFolders folderURL %SERVER_URL% %SERVER_CREDENTIALS% %SERVER_FOLDER_PATH% %ARTICLE_NAME% %LOCAL_FILE_DIR%
call:logEntry %LOG_FILE% "Folder created at %folderURL%"


for /f "tokens=*" %%G in ('dir /b "%LOCAL_FILE_DIR%"') do (
	set manuscriptReturn=
	call:createManuscript manuscriptReturn %SERVER_URL% %SERVER_CREDENTIALS% %SERVER_FOLDER_PATH% %ARTICLE_NAME% %LOCAL_FILE_DIR% %%G %%~nG %MANUSCRIPT_EDITOR%
	call:logEntry %LOG_FILE% "Manuscript created at %manuscriptReturn%"
)

call:logEntry %LOG_FILE% "FINISHED Manuscript Creation"
goto:eof


::--------------------------------------------------------
::-- Create a manuscript
:: Arguments
:: %~1 = The variable to set the return value to
:: %~2 = Server URL
:: %~3 = Server Credentials
:: %~4 = Server Folder Path
:: %~5 = Article Name
:: %~6 = Local Folder
:: %~7 = File to be Uploaded
:: %~8 = Manuscript Editor
::--------------------------------------------------------
:createManuscript
SETLOCAL
	set "RETURN="
	set "FOLDER_PATH=%~4/%~5"
	set "BASE_URL=%~2%FOLDER_PATH%"
	
	::------------- UPLOAD THE ORIGINAL
	set "UPLOAD_CURL_COMMAND=-u %~3 -T %~6\%~7 %BASE_URL%/"
	call:logEntry %LOG_FILE% "createManuscript DEBUG: Upload Curl Command Constructed=%UPLOAD_CURL_COMMAND%"
	
	%CURL% %UPLOAD_CURL_COMMAND% >> %LOG_FILE%
	echo  >> %LOG_FILE%
	
	::------------- CREATE THE MANUSCRIPT
	set "CREATE_URL=%BASE_URL%.createArticle.json"
	call:logEntry %LOG_FILE% "createManuscript DEBUG: Create URL Constructed=%CREATE_URL%"
	
	set DATE_NOW=
	call:getDateTime DATE_NOW
	
	set "PARAMETERS=assignmentName=^&brief=^&editor=%~8^&writer=^&dueDate=^&startDate=%DATE_NOW%^&title=%~8^&targetWordCount=^&create=true^&fileReference=%FOLDER_PATH%/%~7^&_charset_=utf-8"
	set "RETURN=%FOLDER_PATH%/%~7"
	
	set "CREATE_CURL_COMMAND=-u %~3 --data '%PARAMETERS%' %CREATE_URL%"
	
	%CURL% %CREATE_CURL_COMMAND% >> %LOG_FILE%
	echo  >> %LOG_FILE%

ENDLOCAL&set "%~1=%RETURN%"
goto:eof


::--------------------------------------------------------
::-- Creates a Folder, returns the URL to the folder that was created
:: Arguments
:: %~1 = The variable to set the return value to
:: %~2 = Server URL
:: %~3 = Server Credentials
:: %~4 = Server Folder Path
:: %~5 = Article Name
::--------------------------------------------------------
:createFolders
SETLOCAL
	set "BASE_URL=%~2%~4/%~5"
	set "RETURN=%BASE_URL%"
	call:logEntry %LOG_FILE% "createFolders DEBUG: BASE_URL Constructed=%BASE_URL%"
	
	::------------------- CREATE THE BASE URL
	set "BASE_CURL_COMMAND=-u %~3 -F"jcr:primaryType=nt:folder" %BASE_URL%"
	call:logEntry %LOG_FILE% "createFolders DEBUG: BASE_CURL_COMMAND Command Constructed=%BASE_CURL_COMMAND%"
	
	%CURL% %BASE_CURL_COMMAND%  >> %LOG_FILE%
	echo  >> %LOG_FILE%
	
ENDLOCAL&set "%~1=%RETURN%"
goto:eof


::--------------------------------------------------------
::-- Creates a Folder, returns the URL to the folder that was created
:: Arguments
:: %~1 = Log file location
:: %~2 = Log text
::--------------------------------------------------------
:logEntry
SETLOCAL
	set DATE_NOW=
	call:getDateTime DATE_NOW
	echo %DATE_NOW% %~2 >> %~1	
ENDLOCAL
goto:eof


::--------------------------------------------------------
::-- Returns a formatted date time
:: Arguments
:: %~1 = Return variable
::--------------------------------------------------------
:getDateTime
SETLOCAL
	set "DATE_NOW=%date:~-4%-%date:~-3%-%date:~-2%T%time:~0,2%:%time:~3,2%:%time:~6,2%"
ENDLOCAL&set "%~1=%DATE_NOW%"
goto:eof


::--------------------------------------------------------
::-- Returns a formatted date time
:: Arguments
:: %~1 = Return variable
::--------------------------------------------------------
:printHelp
SETLOCAL
	echo cquploadmanuscripts.bat --help (ordered arguments)
	echo    SERVER_URL - The URL that the CQ server will answer on.  do not add a trailing slash!
	echo    SERVER_CREDENTIALS - The credentials used to access CQ (in format username:password).   This should not be an admin user.
	echo    SERVER_FOLDER_PATH - The folder that will be used within the CQ repository.  This folder must already exist in CQ.  Do not add a trailing slash! 
	echo    ARTICLE_NAME - the identifier that will be used for all these imports as well as the folder name for storing the manuscripts
	echo    MANUSCRIPT_EDITOR - This is the assigned editor of the manuscripts, this should be an existing user in CQ
	echo    LOCAL_FILE_DIR - the local folder that contains the folder containing the mutliple text files wanting to be imported
ENDLOCAL
goto:eof


@echo on