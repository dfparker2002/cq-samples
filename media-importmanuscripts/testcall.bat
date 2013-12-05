:: The URL that the CQ server will answer on.  do not add a trailing slash!
set "SERVER_URL=http://localhost:4502" 

:: The credentials used to access CQ (in format username:password).   This should not be an admin user.
set "SERVER_CREDENTIALS=admin:admin"

:: The folder that will be used within the CQ repository.  This folder must already exist in CQ.  Do not add a trailing slash!  
set "SERVER_FOLDER_PATH=/content/dam/uploadtest"

:: the identifier that will be used for all these imports
set "ARTICLE_NAME=mytestarticle"

:: This is the assigned editor of the manuscripts, this should be an existing user in CQ
set "MANUSCRIPT_EDITOR=admin"

:: the local folder that contains the folder containing the mutliple text files wanting to be imported
set "LOCAL_FILE_DIR=C:\Users\dcollie\Workspaces\cni.561\code\manuscriptupload\samples"

cquploadmanuscripts.bat %SERVER_URL% %SERVER_CREDENTIALS% %SERVER_FOLDER_PATH% %ARTICLE_NAME% %MANUSCRIPT_EDITOR% %LOCAL_FILE_DIR%