@echo off
where python >nul 2>nul
if errorlevel 1 (
    where py >nul 2>nul
    if errorlevel 1 (
        echo Python not found. Install Python 3 from https://www.python.org/downloads/ and try again.
        pause
        exit /b 1
    )
    py "%~dp0start.py" %*
    pause
    exit /b
)
python "%~dp0start.py" %*
pause
