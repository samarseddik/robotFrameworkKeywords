#!/usr/bin/env python
"""
Project initialization and verification script.
Validates that all required files and directories are created.
"""

import os
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent

REQUIRED_DIRECTORIES = [
    "keywords/database",
    "keywords/api",
    "keywords/ui",
    "keywords/common",
    "tests/database",
    "tests/api",
    "tests/e2e",
    "resources/config",
    "resources/test-data",
    "resources/fixtures",
    "ci-cd",
    "docker",
    "reports",
    "docs",
]

REQUIRED_FILES = {
    # Keywords
    "keywords/database/DatabaseConnection.robot": "Database connection management",
    "keywords/database/DatabaseCRUD.robot": "CRUD operations",
    "keywords/database/DatabaseValidation.robot": "Data validation",
    "keywords/database/TestDataManagement.robot": "Test data setup/cleanup",
    "keywords/api/APIKeywords.robot": "API testing keywords (placeholder)",
    "keywords/ui/UIKeywords.robot": "UI testing keywords (placeholder)",
    "keywords/common/CommonKeywords.robot": "Common utilities (placeholder)",
    
    # Tests
    "tests/database/01_CRUD_Operations.robot": "CRUD test suite",
    "tests/database/02_Database_Validation.robot": "Validation test suite",
    "tests/database/03_Test_Data_Management.robot": "Test data management suite",
    "tests/database/04_Connection_Management.robot": "Connection management suite",
    
    # Configuration
    "resources/config/config.yaml": "Environment configurations",
    "resources/config/database.yaml": "Database settings",
    "resources/test-data/test_data_schema.json": "Test data schema",
    
    # CI/CD
    "ci-cd/github-actions.yml": "GitHub Actions workflow",
    "ci-cd/gitlab-ci.yml": "GitLab CI pipeline",
    
    # Docker
    "docker/Dockerfile": "Docker image definition",
    "docker/docker-compose.yml": "Docker Compose configuration",
    "docker/init-db.sql": "PostgreSQL initialization",
    "docker/init-mysql.sql": "MySQL initialization",
    
    # Documentation
    "README.md": "Main documentation",
    "docs/DATABASE_KEYWORDS_ARCHITECTURE.md": "Architecture documentation",
    "docs/QUICKSTART.md": "Quick start guide",
    "PROJECT_SUMMARY.md": "Project implementation summary",
    
    # Support files
    "requirements.txt": "Python dependencies",
    ".gitignore": "Git ignore rules",
    "setup.bat": "Windows setup script",
    "setup.sh": "Linux/Mac setup script",
    "Makefile": "Unix Makefile",
    "Makefile.win": "Windows Makefile",
    "project.ini": "Project configuration",
}


def verify_project_structure():
    """Verify that all required files and directories exist."""
    print("=" * 70)
    print("Robot Framework Project Structure Verification")
    print("=" * 70)
    print()
    
    # Check directories
    print("Checking directories...")
    missing_dirs = []
    for dir_path in REQUIRED_DIRECTORIES:
        full_path = PROJECT_ROOT / dir_path
        if full_path.exists() and full_path.is_dir():
            print(f"  ✓ {dir_path}")
        else:
            print(f"  ✗ {dir_path} (MISSING)")
            missing_dirs.append(dir_path)
    
    print()
    
    # Check files
    print("Checking files...")
    missing_files = []
    for file_path, description in REQUIRED_FILES.items():
        full_path = PROJECT_ROOT / file_path
        if full_path.exists() and full_path.is_file():
            size = full_path.stat().st_size
            print(f"  ✓ {file_path} ({size} bytes) - {description}")
        else:
            print(f"  ✗ {file_path} (MISSING) - {description}")
            missing_files.append(file_path)
    
    print()
    print("=" * 70)
    
    # Summary
    total_dirs = len(REQUIRED_DIRECTORIES)
    total_files = len(REQUIRED_FILES)
    missing_count = len(missing_dirs) + len(missing_files)
    
    print(f"Directories: {total_dirs - len(missing_dirs)}/{total_dirs} ✓")
    print(f"Files: {total_files - len(missing_files)}/{total_files} ✓")
    print()
    
    if missing_count == 0:
        print("✓ Project structure is complete!")
        print()
        print("Next steps:")
        print("  1. Activate virtual environment:")
        print("     - Windows: setup.bat")
        print("     - Linux/Mac: bash setup.sh")
        print()
        print("  2. Configure database in: resources/config/config.yaml")
        print()
        print("  3. Run tests:")
        print("     robot tests/database/")
        print()
        print("  4. View reports:")
        print("     Open reports/report.html")
        print()
        return True
    else:
        print(f"✗ Project structure incomplete! {missing_count} item(s) missing:")
        if missing_dirs:
            print("\nMissing directories:")
            for dir_path in missing_dirs:
                print(f"  - {dir_path}")
        if missing_files:
            print("\nMissing files:")
            for file_path in missing_files:
                print(f"  - {file_path}")
        print()
        return False


def print_project_info():
    """Print project information and statistics."""
    print()
    print("=" * 70)
    print("Robot Framework Automated Testing Project")
    print("=" * 70)
    print()
    print("Project Overview:")
    print("  - Framework: Robot Framework 7.0")
    print("  - Focus: Keyword-Driven Database Testing")
    print("  - Keywords: 35+ reusable database keywords")
    print("  - Test Cases: 36 comprehensive test cases")
    print("  - CI/CD: GitHub Actions & GitLab CI support")
    print("  - Containerization: Docker & Docker Compose")
    print()
    print("Key Features:")
    print("  ✓ Multi-database support (PostgreSQL, MySQL, SQLite, MSSQL)")
    print("  ✓ Reusable Keyword-Driven Testing approach")
    print("  ✓ Comprehensive test data management")
    print("  ✓ Built-in validation and verification")
    print("  ✓ CI/CD pipeline integration")
    print("  ✓ Docker support for isolated testing")
    print("  ✓ Allure reporting support")
    print()
    print("Documentation:")
    print("  - README.md - Comprehensive documentation")
    print("  - QUICKSTART.md - 5-minute setup guide")
    print("  - DATABASE_KEYWORDS_ARCHITECTURE.md - Detailed architecture")
    print("  - PROJECT_SUMMARY.md - Implementation summary")
    print()
    print("=" * 70)


if __name__ == "__main__":
    success = verify_project_structure()
    print_project_info()
    sys.exit(0 if success else 1)
