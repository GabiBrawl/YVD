@echo off
color 07
title YVD - Youtube Video Downloader
color 07
set version=2.0
set update_check=False
set data=%appdata%\GabiBrawl\YVD\
set history=%data%history
set temp=%data%temp\
set tools=%data%tools\
set youtube_dl="%tools%youtube-dl.exe"
set ffmpeg="%tools%ffmpeg.exe"
set ffprobe="%tools%ffprobe.exe"
set output_folder=.\Downloads\
set output_mp4=%output_folder%mp4\
set output_mp3=%output_folder%mp3\
set updated_files=%temp%\updated.txt
set script_path=%~dp0
set sp="%script_path:~0,-1%\"
cd %sp%
if not exist %data% mkdir %data%
if not exist %temp% mkdir %temp%
if not exist %tools% (call :tools_download)
if not exist %sp%Downloads (
	md %sp%Downloads
	echo.>>%sp%Downloads\Desktop.ini"
	echo [.ShellClassInfo]>>%sp%Downloads\Desktop.ini"
	echo ConfirmFileOp=0>>%sp%Downloads\Desktop.ini"
	echo IconResource=%%SystemRoot%%\system32\imageres.dll,-184>>%sp%Downloads\Desktop.ini"
	echo [ViewState]>>%sp%Downloads\Desktop.ini"
	echo Mode=>>%sp%Downloads\Desktop.ini"
	echo Vid=>>%sp%Downloads\Desktop.ini"
	echo FolderType=Music>>%sp%Downloads\Desktop.ini"
	attrib +S +H .\Downloads\Desktop.ini
	attrib +R .\Downloads
	start "C:\Windows\System32" ie4uinit.exe -show
)
if %update_check%==True call :update


:main_menu
set choice=
mode con: cols=55 lines=18
cls
echo.
echo                       -YVD v%version%-
echo.
echo.
echo  Available video quality options:
echo   1) mp4 - 360p                  2) mp4 - 480p
echo   3) mp4 - 720p                  4) mp4 - 1080p
echo   5) mp4 - custom quality        6) mp3
echo.
echo  Other options:
echo   a) Help                        b) Update youtube-dl
echo.
echo  Input the value that corresponds to your choice.
set /p choice=^>^> 
if not defined choice call :blank_input && goto main_menu
if %choice% == 1 (set quality=360&& set format=mp4&& goto video_link_input)
if %choice% == 2 (set quality=480&& set format=mp4&& goto video_link_input)
if %choice% == 3 (set quality=720&& set format=mp4&& goto video_link_input)
if %choice% == 4 (set quality=1080&& set format=mp4&& goto video_link_input)
if %choice% == 5 (set format=mp4&& goto custom_quality)
if %choice% == 6 (set quality=bestaudio&& set format=mp3&& goto video_link_input)
if %choice% == a goto Help
if %choice% == b call :Update && goto main_menu
call :invalid_input
goto main_menu


:custom_quality
set quality=
mode con: cols=67 lines=18
cls
echo.
echo                             -YVD v%version%-
echo.
echo.
echo   Input the video quality you want to download.
echo   Suggestions: 144, 240, 1440, 2160, 4320. Just be sure the video
echo  you want to download has that quality option in YouTube.
echo.
echo   To go back, just hit [ENTER]
set /p quality=^>^> 
if not defined quality goto main_menu
goto video_link_input


:video_link_input
setlocal enableextensions enabledelayedexpansion
set address=
mode con: cols=55 lines=21
cls
echo.
echo                  -Video Download Menu-
echo.
echo.
echo   Paste the link of the video you wanna download.
echo   Output Video File Quality: %quality%p, %format%
echo   To go back, just hit [ENTER]
set /p address=^>^> 
if not defined address goto main_menu
echo "%address%"|findstr /R "[%%#^&^^^^@^$~!]" 1>nul
if %errorlevel%==0 (
	setlocal enabledelayedexpansion
	for %%j in (%address%) do (
		set shit=!address:@=_!
	) 
	endlocal
	echo.
    echo   Invalid song name: "%shit%"
    echo   Please remove special symbols: "%#&^@$~!"
	timeout /t 6 >nul
	goto video_link_input
)
if x%address:http://=%==x%address% call :invalid_url && goto video_link_input
if x%address:https://=%==x%address% call :invalid_url && goto video_link_input
if x%address:www.youtube.com/watch?v=%==x%address% call :invalid_url && goto video_link_input
if x%address:youtube.com/watch?v=%==x%address% call :invalid_url && goto video_link_input
endlocal
cls
echo.
echo                  -Video Download Menu-
echo.
echo.
set hour=%time:~0,2%
set minute=%time:~3,2%
set day=%date:~0,2%
set month=%date:~3,2%
if not exist %history% md %history%
set "history_file=%history%\%day%-%month%.txt"
echo ^>^> %hour%:%minute%Hrs>>"%history_file%"
echo %address% >>"%history_file%"
echo. >>"%history_file%"
%youtube_dl% "%address%" -e --get-title > %temp%\vid_name_temp.txt
%youtube_dl% "%address%" --get-duration > %temp%\vid_duration_temp.txt
set /p vid_title= < %temp%\vid_name_temp.txt 
set /p vid_duration= < %temp%\vid_duration_temp.txt
del /f /q %temp%\vid_name_temp.txt 
del /f /q %temp%\vid_duration_temp.txt
echo  Downloading "%vid_title%", with the lengh of %vid_duration%...
if %format%==mp3 (
	  %youtube_dl% --extract-audio --audio-format mp3 "%address%" -c
	  move *.mp3 %sp%Downloads
)
if %format%==mp4 (
	  %youtube_dl% --format "bestvideo[height=%quality%][ext=%format%]+bestaudio" "%address%" -c
	  move *.mp4 %sp%Downloads
)
goto main_menu


:tools_download
mode con: cols=65 lines=21
mkdir %tools%
cls
echo.
echo                -Downloading needed Tools-
echo     It can seem like the program is frozen, but it's not
echo      just let it do its thing. This will depend on your
echo          connection speed, so it can take a while.
echo.
echo.
echo  Downloading youtube-dl...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://yt-dl.org/downloads/latest/youtube-dl.exe', '%tools%youtube-dl.exe')"
echo.
echo  Downloading ffmpeg...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://github.com/GabiBrawl/SPOTYdl/raw/main/server/ffmpeg5.0_x64.zip', '%tools%ffmpeg.zip')"
echo  Extracting ffmpeg...
powershell -Command "Expand-Archive -Path '%tools%ffmpeg.zip' -DestinationPath '%tools%'"
echo  Deleting ffmpeg.zip...
del /f /q "%tools%ffmpeg.zip"
echo.
echo  Done!
timeout /t 5 >nul
exit /b


:Update
mode con: cols=56 lines=14  
cls
echo.
echo                  -Checking for Updates-
echo.
echo.
if exist "%updated_files%" del /f /q "%updated_files%"
%youtube_dl% -U >"%updated_files%"
set /p update=<"%updated_files%"
SETLOCAL ENABLEDELAYEDEXPANSION
set update=!update:(=!
set update=!update:)=!
SETLOCAL DISABLEDELAYEDEXPANSION
echo %update% >"%updated_files%"
echo.
for /f "tokens=1-5 delims= " %%a in ('type "%updated_files%"') do (
	set file=%%a
	set data=%%d
	)
for /f "tokens=1,2,3 delims=. " %%a in ("%data%") do (
	set data=%%c.%%b.%%a
	)
if "%file%"=="can't" (
	set file=youtubedl
	set data=verified
) 
echo  File:		%file%
echo  Version:	%data%
if exist "%updated_files%" del /f /q "%updated_files%"
timeout 4 >nul
exit /b


:Help
cls
echo.
echo                   -Help Menu-
echo.
echo.
:HelpDownload
cls
echo For download you have just
echo to press 1 in the main menu,
echo and hit enter.
echo Then you have to paste the
echo link of the download of the file.
pause
goto main_menu


:HelpUpdate
cls
echo For Update you have just
echo to press 4 in the main menu,
echo and hit enter.
echo Then you have just to wait. the
echo program will update your service automaticly.
pause
goto menu


:invalid_input
echo  The value you entered is invalid. Try again!
timeout /t 3 >nul
exit /b
:blank_input
echo  You can't leave this field in blank. Try again!
timeout /t 3 >nul
exit /b
:press_any_key
echo  Press any key to go back...
pause >nul
exit /b
:invalid_url
echo  The URL you entered is invalid. Try again!
timeout /t 3 >nul
exit /b