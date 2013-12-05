DESCRIPTION:
Batch script sample to show how to upload text assets to the DAM, and then convert these text assets into Manuscripts within the repository.   This allows for the scripting of output from external workflow systems to input the data into the DAM in an automated fashion (e.g. K4)

INSTRUCTIONS:
1. cquploadmanuscripts.bat is the script that does the actual upload/manuscript creation.
2. you can test it by changing the vars in testcall.bat, and executing it.
3. whatever you set as the SERVER_FOLDER_PATH argument, it must already exist in the repository

IMPORTANT NOTE: 
This code is provided as is, with  no support or warranty.   Please test in a non production environment and ensure you are happy with the results.  This is not an official bit of code and is purely a sample to get started with.