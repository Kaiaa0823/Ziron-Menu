@echo off
setlocal enabledelayedexpansion

	:: Set THIS_VERSION to the version of this batch file script
	set THIS_VERSION=1.0.05

	:: Set SCRIPT_NAME to the name of this batch file script
	set SCRIPT_NAME=Ziron Menu

	:: Set GH_USER_NAME to your GitHub username here
	set GH_USER_NAME=Kaiaa0823

	:: Set GH_REPO_NAME to your GitHub repository name here
	set GH_REPO_NAME=Ziron-Menu

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

	TITLE !SCRIPT_NAME! (v!THIS_VERSION!)

:SetUpTempDir

	:: Setting up the Temp Directory
	CD /D "%temp%"
		IF exist "!GH_REPO_NAME!-UDPATE" RD /S /Q "!GH_REPO_NAME!-UDPATE"
		MD "!GH_REPO_NAME!-UDPATE"
		
	CD /D "!GH_REPO_NAME!-UDPATE"

:GetLatestVerNum

	:: URL to fetch JSON data from GitHub API
	set "GH_LATEST_RLS_PAGE=https://api.github.com/repos/!GH_USER_NAME!/!GH_REPO_NAME!/releases/latest"
	set "URL_TO_DOWNLOAD=!GH_LATEST_RLS_PAGE!"
	set "LATEST_VERSION="
	
	:RedirectLooop

		if exist response.json del /Q response.json
		
		:: Use CURL to download the JSON data
		curl -s -o response.json !URL_TO_DOWNLOAD!
		
			if not exist "response.json" (
			
			ECHO.
			ECHO.
			ECHO -------
			ECHO  ERROR
			ECHO -------
			ECHO.
			ECHO Something went wrong with downloading the latest release information.
			ECHO.
			ECHO.
			ECHO Press any key to continue with this version of the batch file or
			ECHO just close this window...
			ECHO NOTE-I will open the releases page for you to see if there is a newer version.
			
			PAUSE>NUL
			START "" "!GH_LATEST_RLS_PAGE!"
			GOTO UpdateCleanUp
			)
		
		::Check if "exceeded" is present in the JSON, if so it likely means the API Call limit has been reached.
		findstr /C:"exceeded" response.json
			if "%errorlevel%"=="0" (
				ECHO.
				ECHO.
				ECHO -------
				ECHO  ERROR
				ECHO -------
				ECHO.
				ECHO While trying to get the latest version number for this batch file from GitHub,
				ECHO I found that the number of requests has been exceeded.
				ECHO You can try again in a while.
				ECHO.
				ECHO.
				ECHO Press any key to continue with this version of the batch file or
				ECHO just close this window...
				ECHO NOTE-I will open the releases page for you to see if there is a newer version.
				
				PAUSE>NUL
				START "" "!GH_LATEST_RLS_PAGE!"
				GOTO UpdateCleanUp
			)
				
		:: Check if "tag_name" is present in the JSON.
		findstr /C:"tag_name" response.json
			if "%errorlevel%"=="0" (
				:: tag_name Found in file which means there was no redirect or this is the final redirect
				:: page and has the version number on it.
				:: Extract the text between the second set of quotes and remove the first character (usually a lower case v).
				for /f "tokens=2 delims=:" %%a in ('findstr /C:"tag_name" response.json') do (
					set "LATEST_VERSION=%%~a"
					set "LATEST_VERSION=!LATEST_VERSION:~3,-2!"
				)
			) else (
				:: tag_name was not found which means that this is likely a redirect page.
				:: Extract the line that has "https://api." and grab the URL between the second set of quotes.
				:: Feed this URL back through the loop to see if this one redirects too. If it does, keep following until tag_name is found.
				for /f "tokens=1,* delims=" %%a in ('findstr /C:"https://api." response.json') do (
					set "URL_TO_DOWNLOAD=%%~a"
					set "URL_TO_DOWNLOAD=!URL_TO_DOWNLOAD:~10,-2!"
				)
				goto RedirectLooop
			)

:DoYouHaveLatest
	
	:: If the current version matches the latest version available, contine on with normal code.
	if /i "!THIS_VERSION!"=="!LATEST_VERSION!" goto UpdateCleanUp

:UpdateAvailablePrompt

	cls
	
	ECHO.
	ECHO.
	ECHO * * * * * * * * * * * * *
	ECHO     UPDATE AVAILABLE
	ECHO * * * * * * * * * * * * *
	ECHO.
	ECHO.
	ECHO GITHUB VERSION: !LATEST_VERSION!
	ECHO YOUR VERSION:   !THIS_VERSION!
	ECHO.
	ECHO.
	ECHO.
	ECHO  CHOICES:
	ECHO.
	ECHO     U   -   MANUALLY DOWNLOAD THE NEWEST BATCH FILE UPDATE AND USE THAT FILE.
	ECHO.
	ECHO     C   -   CONTINUE USING THIS FILE.
	ECHO.
	ECHO.
	ECHO.

	SET UPDATE_CHOICE=NO_CHOICE_MADE

	SET /p UPDATE_CHOICE=Please type either M, or C and press Enter: 
		if /I %UPDATE_CHOICE%==U GOTO UPDATE
		if /I %UPDATE_CHOICE%==C GOTO UpdateCleanUp
		goto UpdateAvailablePrompt
	
:UPDATE
	
	set GH_LATEST_RLS_PAGE=https://github.com/!GH_USER_NAME!/!GH_REPO_NAME!/releases/latest
	
	CLS
	
	START "" "!GH_LATEST_RLS_PAGE!"
	
	ECHO.
	ECHO.
	ECHO GO TO THE FOLLOWING WEBSITE, DOWNLOAD AND USE THE LATEST VERSION OF %~nx0
	ECHO.
	ECHO    !GH_LATEST_RLS_PAGE!
	ECHO.
	ECHO Press any key to exit...
	
	pause>nul
	
	exit

:UpdateCleanUp

	cls
	
	CD /D "%temp%"
		IF exist "!GH_REPO_NAME!-UDPATE" RD /S /Q "!GH_REPO_NAME!-UDPATE"
	
	:: Ensures the directory is back to where this batch file is hosted.
	CD /D "%~dp0"

:RestOfCode

	CLS

	:: Here is where your normal code will go after the update process is done.
	ECHO.
	ECHO.
	ECHO VERSION CHECK COMPLETE, Do some other stuff now.
	ECHO.
	ECHO.

	pause
	
	EXIT