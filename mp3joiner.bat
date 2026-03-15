:: Batch file is in beta. Current code needs more testing.
:: The ffmpeg command to concatenate two or more mp3 files is as follows
:: ffmpeg -f concat -safe 0 -i mp3list.txt -c copy "%output%"

@echo off
:start

:: Check if ffmpeg is available
where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo Error: ffmpeg.exe not found in PATH.
    echo Please install ffmpeg or add it to PATH.
    pause
    exit /b
)

:: Ask user for directory
set /p Directory="DirectoryPath: "

:: Check if directory exists. If so, navigate to directory. If not, display error message and return to start.
if not exist "%Directory%" (
    echo Error: Directory does not exist.
    goto :Start
)

cd /d "%Directory%"

:: Count mp3 files
setlocal EnableDelayedExpansion
set count=0

:: Create a temporary textfile containing the list of mp3 files
dir /b /on *.mp3 > sortedlist.txt

for /f "usebackq delims=" %%f in ("sortedlist.txt") do (
    set /a count+=1
)

:: Make sure there's at least two mp3 files in the first place. Display error message if not.
if !count! lss 2 (
    echo Error: Less than 2 MP3 files in the directory.
    del sortedlist.txt
    endlocal
    goto :Start
)

:: Create ffmpeg concat list
> mp3list.txt (
    for /f "usebackq delims=" %%f in ("sortedlist.txt") do (
        echo file '%%f'
    )
)

:: Generate safe timestamp for output filename
set "ts=%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "ts=%ts:/=_%"
set "ts=%ts::=_%"
set "ts=%ts: =0%"

:: Add random number to ensure uniqueness
set "output=joined_%ts%_%random%.mp3"

:: Run ffmpeg to concatenate
ffmpeg -f concat -safe 0 -i mp3list.txt -c copy "%output%"

:: Clean up
del mp3list.txt
del sortedlist.txt
endlocal

echo Successfully created: %output%
goto :Start