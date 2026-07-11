# Quick Start Guide

## Installation (5 minutes)

### Step 1: Clone Repository
```bash
git clone <repository-url>
cd robotFrameworkKeywords
```

### Step 2: Setup Python Environment
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

### Step 3: Install Dependencies
```bash
pip install -r requirements.txt
python -m playwright install
```

### Step 4: Configure Database
Edit `resources/config/config.yaml` with your database details.

## Running Your First Test (5 minutes)

### Option 1: Using Local Database
```bash
# Ensure your database is running and configured
robot tests/database/01_CRUD_Operations.robot
```

### Option 2: Using Docker
```bash
# Start services
docker-compose -f docker/docker-compose.yml up -d

# Run tests in container
docker-compose -f docker/docker-compose.yml exec robot-runner \
  robot tests/database/

# Stop services
docker-compose -f docker/docker-compose.yml down
```

## Writing Your First Test

### Test Template
```robot
*** Settings ***
Documentation    Your test description
Suite Setup      Connect To Database With Config
Suite Teardown   Disconnect From Database
Test Setup       Setup Test Database
Test Teardown    Cleanup Test Data

Resource         ../../keywords/database/DatabaseConnection.robot
Resource         ../../keywords/database/DatabaseCRUD.robot
Resource         ../../keywords/database/DatabaseValidation.robot


*** Test Cases ***
My First Test
    [Documentation]    What this test does
    
    # Create test data
    Create Record In Table    users    username=testuser    email=test@example.com
    
    # Verify the data
    Verify Record Exists    users    username='testuser'
    
    # Clean up happens automatically in Test Teardown
```

### Save and Run
```bash
# Save as: tests/database/my_first_test.robot
robot tests/database/my_first_test.robot
```

## Common Operations

### 1. Create Data
```robot
Create Record In Table    users
...    username=john
...    email=john@example.com
...    first_name=John
...    last_name=Doe
```

### 2. Read Data
```robot
${user}=    Read Record By Id    users    1
${all_users}=    Read Records From Table    users
${active_users}=    Read Records From Table    users    is_active = true
```

### 3. Update Data
```robot
Update Record By Id    users    1    email=newemail@example.com
```

### 4. Delete Data
```robot
Delete Record By Id    users    1
```

### 5. Verify Data
```robot
Verify Record Exists    users    username='john'
Verify Column Value    users    id=1    email    john@example.com
Verify Table Record Count    users    10
```

## View Test Results

### HTML Reports
```bash
# Reports are in: reports/
# Open: reports/report.html in browser
```

### Allure Reports
```bash
allure generate reports --clean -o allure-results
allure open allure-results/
```

## Troubleshooting

### Connection Failed
```bash
# Check database is running
# Check credentials in config.yaml
# Check host and port are correct

# Test connection manually
psql -h localhost -U test_user -d test_db  # PostgreSQL
mysql -h localhost -u test_user -p test_password test_db  # MySQL
```

### Tests Fail
```bash
# Check logs in reports/log.html
# Add verbose output
robot -v LOGLEVEL:DEBUG tests/database/

# Check database state
# Ensure setup/teardown are running properly
```

### Import Errors
```bash
# Reinstall dependencies
pip install -r requirements.txt --upgrade --force-reinstall

# Reinstall Playwright
python -m playwright install --with-deps
```

## Next Steps

1. ✅ Run the existing test suites
2. ✅ Modify tests for your application
3. ✅ Create new keywords for your specific needs
4. ✅ Setup CI/CD pipeline
5. ✅ Monitor test results and coverage

## Resources

- [Robot Framework Documentation](https://robotframework.org)
- [RPA.Database Library](https://rpa-framework.org/libraries/database/index.html)
- [Project Architecture](./DATABASE_KEYWORDS_ARCHITECTURE.md)
- [Full README](../README.md)

## Support

For help:
1. Check existing test examples
2. Review keyword documentation
3. Check CI/CD logs for failures
4. Create an issue with error details
