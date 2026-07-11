#!/bin/bash
# Robot Framework Test Project Setup Script for Linux/Mac

echo ""
echo "========================================"
echo "Robot Framework Automated Testing Setup"
echo "========================================"
echo ""

# Check Python installation
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed or not in PATH"
    exit 1
fi

echo "[1/4] Creating virtual environment..."
python3 -m venv venv
if [ $? -ne 0 ]; then
    echo "Error: Failed to create virtual environment"
    exit 1
fi

echo "[2/4] Activating virtual environment..."
source venv/bin/activate
if [ $? -ne 0 ]; then
    echo "Error: Failed to activate virtual environment"
    exit 1
fi

echo "[3/4] Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies"
    exit 1
fi

echo "[4/4] Installing Playwright browsers..."
python -m playwright install
if [ $? -ne 0 ]; then
    echo "Warning: Playwright installation had issues (non-critical)"
fi

echo ""
echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Activate virtual environment: source venv/bin/activate"
echo "2. Configure database: Edit resources/config/config.yaml"
echo "3. Run tests: robot tests/database/"
echo "4. View reports: Open reports/report.html"
echo ""
