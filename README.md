# Robot Framework Automated Testing Project

## 📋 Project Overview

This project implements a **Keyword-Driven Testing** strategy using **Robot Framework** for automated testing, with a focus on **database testing** operations. The strategy encompasses a comprehensive testing pyramid including unit tests, API tests, and end-to-end tests, all built on reusable, configurable keywords.

## 🎯 Project Objectives

- ✅ Define a global automated testing strategy (unit, API, E2E)
- ✅ Implement reusable and configurable test architecture
- ✅ Adopt Keyword-Driven Testing approach
- ✅ Integrate tests into CI/CD pipelines
- ✅ Validate strategy on real-world applications

## 📦 Project Structure

```
robotFrameworkKeywords/
├── keywords/                    # Reusable keyword libraries
│   ├── database/               # Database-specific keywords
│   │   ├── DatabaseConnection.robot    # Connection management
│   │   ├── DatabaseCRUD.robot          # Create, Read, Update, Delete
│   │   ├── DatabaseValidation.robot    # Data verification
│   │   └── TestDataManagement.robot    # Fixtures and test data
│   ├── api/                    # API testing keywords (placeholder)
│   ├── ui/                     # UI testing keywords (placeholder)
│   └── common/                 # Common utilities
├── tests/                      # Test suites
│   ├── database/              # Database tests
│   │   ├── 01_CRUD_Operations.robot
│   │   ├── 02_Database_Validation.robot
│   │   ├── 03_Test_Data_Management.robot
│   │   └── 04_Connection_Management.robot
│   ├── api/                   # API tests (placeholder)
│   └── e2e/                   # End-to-end tests (placeholder)
├── resources/                 # Configuration and test data
│   ├── config/               # Configuration files
│   │   ├── config.yaml       # Environment configurations
│   │   └── database.yaml     # Database settings
│   ├── test-data/            # Test data files
│   │   └── test_data_schema.json
│   └── fixtures/             # Test fixtures
├── ci-cd/                    # CI/CD pipeline configurations
│   ├── github-actions.yml    # GitHub Actions workflow
│   └── gitlab-ci.yml         # GitLab CI configuration
├── docker/                   # Docker configurations
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── init-db.sql
│   └── init-mysql.sql
├── reports/                  # Test reports and logs
├── docs/                     # Documentation
└── requirements.txt          # Python dependencies
```

## 🔧 Technology Stack

| Component | Technology |
|-----------|-----------|
| Framework | Robot Framework 7.0 |
| Database Operations | RPA.Database |
| UI/E2E Testing | Playwright |
| API Testing | Robot Framework Requests |
| Configuration | YAML/JSON |
| Reporting | Robot Framework Reports + Allure |
| CI/CD | GitHub Actions / GitLab CI |
| Containerization | Docker / Docker Compose |

## 📥 Installation

### Prerequisites
- Python 3.9+
- PostgreSQL/MySQL (or SQLite for development)
- Docker & Docker Compose (optional)

### 1. Clone the Repository
```bash
git clone <repository-url>
cd robotFrameworkKeywords
```

### 2. Create Python Virtual Environment
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
python -m playwright install
```

### 4. Configure Database Connection
Edit `resources/config/config.yaml` with your database credentials:

```yaml
environments:
  development:
    database:
      host: localhost
      port: 5432
      username: test_user
      password: test_password
      database: test_db
      driver: postgresql
```

## 🐳 Docker Setup

### Using Docker Compose
```bash
# Start all services
docker-compose -f docker/docker-compose.yml up -d

# Run tests in container
docker-compose -f docker/docker-compose.yml exec robot-runner robot tests/database/

# Stop services
docker-compose -f docker/docker-compose.yml down
```

## 🧪 Running Tests

### Run All Database Tests
```bash
robot tests/database/
```

### Run Specific Test Suite
```bash
# CRUD Operations
robot tests/database/01_CRUD_Operations.robot

# Database Validation
robot tests/database/02_Database_Validation.robot

# Test Data Management
robot tests/database/03_Test_Data_Management.robot

# Connection Management
robot tests/database/04_Connection_Management.robot
```

### Run with Variables
```bash
robot \
  --variable DB_HOST:localhost \
  --variable DB_PORT:5432 \
  --variable DB_NAME:test_db \
  --variable DB_USER:test_user \
  --variable DB_PASSWORD:test_password \
  tests/database/
```

### Generate Reports
```bash
# Robot Framework HTML Reports
robot -d reports tests/database/

# Allure Reports
allure generate reports --clean -o allure-results
allure open allure-results/
```

## 📚 Keyword-Driven Testing Approach

### Database Connection Keywords
- `Connect To Database With Config` - Establish database connection
- `Verify Database Connection` - Test connectivity
- `Disconnect From Database` - Close connection
- `Configure Database Connection Parameters` - Update connection settings

### CRUD Operation Keywords
- `Create Record In Table` - Insert new records
- `Read Records From Table` - Query records with filters
- `Read Record By Id` - Fetch single record by ID
- `Update Record In Table` - Modify existing records
- `Delete Record From Table` - Remove records
- `Count Records In Table` - Get record count

### Validation Keywords
- `Verify Record Exists` - Assert record presence
- `Verify Column Value` - Validate column data
- `Verify Multiple Column Values` - Check multiple columns
- `Verify Table Is Empty` - Assert empty table
- `Verify Table Record Count` - Validate record count
- `Verify Foreign Key Relationship` - Check referential integrity

### Test Data Management Keywords
- `Setup Test Database` - Initialize test environment
- `Insert Test Data Fixture` - Load predefined test data
- `Create Test User` - Create test user record
- `Create Test Product` - Create test product
- `Cleanup Test Data` - Remove test data
- `Truncate All Test Tables` - Clear table data

## 🔄 CI/CD Integration

### GitHub Actions
- Workflow: `.github/workflows/robot-tests.yml`
- Automatically runs on push/PR
- Executes all test suites
- Generates reports and artifacts

### GitLab CI
- Configuration: `ci-cd/gitlab-ci.yml`
- Parallel test execution
- Automated reporting
- Docker-based test runner

## 📊 Test Coverage

| Category | Tests | Status |
|----------|-------|--------|
| CRUD Operations | 8 | ✅ |
| Database Validation | 11 | ✅ |
| Test Data Management | 11 | ✅ |
| Connection Management | 6 | ✅ |
| **Total** | **36** | ✅ |

## 🎨 Example Test Case

```robot
*** Test Cases ***
Test Create User Record
    [Documentation]    Test creating a new user record in the database.
    
    Create Record In Table    users
    ...    username=newuser
    ...    email=newuser@example.com
    ...    password_hash=hashed_password_123
    ...    first_name=New
    ...    last_name=User
    
    Verify Record Exists    users    username = 'newuser'
```

## 🔐 Best Practices

1. **Keyword Reusability**: Create general keywords that can be used in multiple test scenarios
2. **Test Independence**: Each test should be independent and not rely on other tests
3. **Data Cleanup**: Always clean up test data after each test
4. **Configuration Management**: Use YAML/JSON configs for environment-specific settings
5. **Logging**: Enable DEBUG logging for troubleshooting
6. **Documentation**: Include clear documentation in keyword and test descriptions

## 📖 Future Enhancements

- [ ] API Testing Keywords
- [ ] UI Testing Keywords (Playwright)
- [ ] Performance Testing Keywords
- [ ] Security Testing Keywords
- [ ] Data-Driven Testing Examples
- [ ] Advanced Reporting with Allure
- [ ] Test Scheduling and Monitoring
- [ ] Integration with Test Management Tools

## 🐛 Troubleshooting

### Database Connection Issues
```bash
# Test PostgreSQL connection
psql -h localhost -U test_user -d test_db

# Check environment variables
echo %DB_HOST% (Windows)
echo $DB_HOST (Linux/Mac)
```

### Playwright Issues
```bash
# Reinstall Playwright
python -m playwright install --with-deps
```

### Report Generation Issues
```bash
# Install Allure
choco install allure (Windows)
brew install allure (Mac)
apt-get install allure (Linux)
```

## 📝 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👥 Contributors

- Project Lead: [Your Name]
- Contact: [Your Email]

## 📞 Support

For issues, questions, or suggestions:
1. Check the documentation in `docs/`
2. Review test examples
3. Create an issue in the repository

---

**Last Updated**: May 2026
