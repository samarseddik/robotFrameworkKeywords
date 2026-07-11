@echo off
REM Robot Framework Test Project Setup Script for Windows

echo.
echo ========================================
echo Robot Framework Automated Testing Setup
echo ========================================
echo.

REM Check Python installation
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    exit /b 1
)

echo [1/4] Creating virtual environment...
python -m venv venv
if errorlevel 1 (
    echo Error: Failed to create virtual environment
    exit /b 1
)

echo [2/4] Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo Error: Failed to activate virtual environment
    exit /b 1
)

echo [3/4] Installing dependencies...
pip install --upgrade pip
pip install -r requirements.txt
if errorlevel 1 (
    echo Error: Failed to install dependencies
    exit /b 1
)

echo [4/4] Installing Playwright browsers...
python -m playwright install
if errorlevel 1 (
    echo Warning: Playwright installation had issues (non-critical)
)

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Activate virtual environment: venv\Scripts\activate.bat
echo 2. Configure database: Edit resources/config/config.yaml
echo 3. Run tests: robot tests/database/
echo 4. View reports: Open reports/report.html
echo.
