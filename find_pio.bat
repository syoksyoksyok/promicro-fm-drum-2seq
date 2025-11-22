@echo off
REM ========================================
REM PlatformIO Location Finder
REM ========================================

echo Searching for PlatformIO...
echo.

REM 方法1: whereコマンドで検索
where pio.exe 2>nul
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Found via 'where' command!
    goto :end
)

REM 方法2: よくある場所を検索
set "SEARCH_PATHS=%USERPROFILE%\.platformio %LOCALAPPDATA%\Programs\Python %APPDATA%\Python"

for %%P in (%SEARCH_PATHS%) do (
    if exist "%%P" (
        echo Searching in: %%P
        dir /s /b "%%P\pio.exe" 2>nul
    )
)

echo.
echo If PlatformIO was found above, copy one of the paths.
echo.

REM 方法3: Pythonのスクリプトフォルダを検索
echo Checking Python Scripts folders...
for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python*") do (
    if exist "%%D\Scripts\pio.exe" (
        echo Found: %%D\Scripts\pio.exe
    )
)

for /d %%D in ("%APPDATA%\Python\Python*") do (
    if exist "%%D\Scripts\pio.exe" (
        echo Found: %%D\Scripts\pio.exe
    )
)

echo.
echo Checking .platformio folder...
if exist "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" (
    echo Found: %USERPROFILE%\.platformio\penv\Scripts\pio.exe
)

:end
echo.
echo ========================================
echo  Search Complete
echo ========================================
echo.
pause
