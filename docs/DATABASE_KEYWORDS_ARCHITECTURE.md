# Database Keywords Architecture

## Overview
The database keywords are organized into reusable, functional modules following the Keyword-Driven Testing methodology. Each module focuses on a specific aspect of database testing.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      Test Cases                              │
│  (01_CRUD | 02_Validation | 03_TestData | 04_Connection)   │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   Keyword Libraries                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────┐  ┌──────────────────┐                  │
│  │ DatabaseCRUD    │  │ DatabaseValidate │                  │
│  │ Keywords        │  │ Keywords         │                  │
│  ├─────────────────┤  ├──────────────────┤                  │
│  │ • Create Record │  │ • Verify Exists  │                  │
│  │ • Read Records  │  │ • Verify Values  │                  │
│  │ • Update Record │  │ • Verify Counts  │                  │
│  │ • Delete Record │  │ • Verify Schema  │                  │
│  └─────────────────┘  └──────────────────┘                  │
│                                                              │
│  ┌──────────────────┐  ┌────────────────────┐              │
│  │ TestDataMgmt     │  │ DatabaseConnection │              │
│  │ Keywords         │  │ Keywords           │              │
│  ├──────────────────┤  ├────────────────────┤              │
│  │ • Setup DB       │  │ • Connect          │              │
│  │ • Insert Fixture │  │ • Verify Connect   │              │
│  │ • Create User    │  │ • Disconnect       │              │
│  │ • Cleanup Data   │  │ • Configure        │              │
│  └──────────────────┘  └────────────────────┘              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   RPA.Database Library                       │
│              (Robot Framework Built-in)                      │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   Database Drivers                           │
│     (PostgreSQL | MySQL | SQLite | MSSQL)                   │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  Actual Databases                            │
└─────────────────────────────────────────────────────────────┘
```

## Module Breakdown

### 1. DatabaseConnection.robot
**Purpose**: Manage database connections and session lifecycle

**Keywords**:
- `Connect To Database With Config` - Establishes connection with parameters
- `Build Connection String` - Creates driver-specific connection strings
- `Verify Database Connection` - Tests connectivity
- `Disconnect From Database` - Closes active connection
- `Get Database Connection Status` - Returns current status
- `Configure Database Connection Parameters` - Updates runtime parameters

**Usage Pattern**:
```robot
Suite Setup    Connect To Database With Config
Suite Teardown    Disconnect From Database
```

### 2. DatabaseCRUD.robot
**Purpose**: Provide business-level keywords for data manipulation

**Keywords**:
- `Create Record In Table` - INSERT operations
- `Read Records From Table` - SELECT queries with filters
- `Read Record By Id` - Fetch by primary key
- `Update Record In Table` - UPDATE operations
- `Delete Record From Table` - DELETE operations
- `Count Records In Table` - COUNT queries
- `Execute Custom Query` - Raw SQL execution

**Usage Pattern**:
```robot
Create Record In Table    users    username=john    email=john@example.com
${records}=    Read Records From Table    users    WHERE email LIKE '%@example.com%'
Update Record By Id    users    1    email=newemail@example.com
```

### 3. DatabaseValidation.robot
**Purpose**: Assert and validate database state and integrity

**Keywords**:
- `Verify Record Exists` - Assert record presence
- `Verify Column Value` - Assert column data
- `Verify Table Record Count` - Assert count
- `Verify Unique Constraint` - Check uniqueness
- `Verify Foreign Key Relationship` - Check referential integrity
- `Verify Column Exists` - Check schema
- `Verify Data Type` - Check column type

**Usage Pattern**:
```robot
Verify Record Exists    users    username='john'
Verify Column Value    users    id=1    email    john@example.com
Verify Table Record Count    users    100
```

### 4. TestDataManagement.robot
**Purpose**: Handle test data setup, fixtures, and cleanup

**Keywords**:
- `Setup Test Database` - Create tables
- `Insert Test Data Fixture` - Load predefined data
- `Create Test User` - Create sample user
- `Create Test Product` - Create sample product
- `Cleanup Test Data` - Remove test data
- `Truncate All Test Tables` - Clear data

**Usage Pattern**:
```robot
Test Setup    Setup Test Database
Test Teardown    Cleanup Test Data

Insert Test Data Fixture    users
${user}=    Create Test User    testuser    testuser@example.com
```

## Design Patterns

### 1. Business-Level Abstraction
Keywords are written at business level, not technical SQL level:

**❌ Avoid**:
```robot
Query    SELECT * FROM users WHERE id = 1
```

**✅ Use**:
```robot
${user}=    Read Record By Id    users    1
```

### 2. Keyword Composition
Complex operations are built from simpler keywords:

```robot
Test Complete User Workflow
    Create Test User    testuser    test@example.com
    Verify Record Exists    users    username='testuser'
    Update Record By Id    users    1    email=new@example.com
    Verify Column Value    users    id=1    email    new@example.com
    Cleanup Test User    testuser
```

### 3. Flexible Configuration
Keywords accept optional parameters for flexibility:

```robot
Connect To Database With Config
...    host=localhost
...    port=5432
...    database=prod_db
...    user=admin
```

### 4. Consistent Error Handling
All keywords include proper logging and error messages:

```robot
Should Not Be Empty    ${result}    Record not found matching criteria
Should Be Equal    ${actual}    ${expected}    Column value mismatch
```

## Usage Scenarios

### Scenario 1: Simple Data Validation
```robot
Test User Email Unique
    Connect To Database With Config
    Create Test User    user1    unique@example.com
    Verify Unique Constraint    users    email    unique@example.com
    Disconnect From Database
```

### Scenario 2: Complex Business Logic
```robot
Test Order Processing Workflow
    [Setup]    Setup Test Database
    
    # Create test data
    ${user}=    Create Test User    buyer    buyer@example.com
    ${product}=    Create Test Product    Laptop    999.99    5
    
    # Verify initial state
    Verify Column Value    products    id=1    quantity    5
    
    # Create order
    Create Test Order    1    1    2    1999.98
    
    # Verify order
    Verify Record Exists    orders    user_id=1 AND product_id=1
    
    # Verify quantity reduced (simulated)
    Update Record In Table    products    id=1    quantity=3
    Verify Column Value    products    id=1    quantity    3
    
    [Teardown]    Cleanup Test Data
```

### Scenario 3: Data Integrity Testing
```robot
Test Referential Integrity
    Setup Test Database
    
    Insert Test Data Fixture    users
    Insert Test Data Fixture    products
    Insert Test Data Fixture    orders
    
    # Verify foreign keys
    Verify Foreign Key Relationship    users    1    orders    user_id    1
    Verify Foreign Key Relationship    products    1    orders    product_id    1
    
    # Verify data consistency
    ${user_count}=    Count Records In Table    users
    ${order_user_ids}=    Execute Custom Query    SELECT DISTINCT user_id FROM orders
    
    Should Be True    ${order_user_ids.__len__()} <= ${user_count}
```

## Configuration Files

### config.yaml
- Environment-specific database configurations
- Connection parameters (host, port, credentials)
- Timeout settings
- Database driver specifications

### database.yaml
- Supported database drivers
- Connection pool settings
- Query timeout values
- Isolation levels

### test_data_schema.json
- Table schema definitions
- Field types and constraints
- Sample test data structure

## Best Practices

1. **Always Use Keywords**: Never write raw SQL in tests
2. **Keyword Composition**: Build complex tests from simple keywords
3. **Clear Naming**: Use descriptive keyword and variable names
4. **Documentation**: Include docstrings in all keywords
5. **Error Handling**: Always verify expected outcomes
6. **Data Cleanup**: Never leave test data in database
7. **Logging**: Use appropriate log levels (DEBUG, INFO, WARN)
8. **Configuration**: Use config files, not hardcoded values

## Performance Considerations

- Connection pooling for batch operations
- Use `Truncate` instead of `Delete` for speed
- Batch inserts for large datasets
- Proper indexing on frequently queried columns
- Connection timeout settings for slow databases

## Future Enhancements

- [ ] Database transaction support
- [ ] Stored procedure execution
- [ ] Batch operations optimization
- [ ] Database comparison keywords
- [ ] Backup and restore operations
- [ ] Performance profiling keywords
- [ ] Data migration validation
