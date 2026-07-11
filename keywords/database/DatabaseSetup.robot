*** Settings ***
Documentation    Reusable keywords for test data setup, teardown, and management.
...              Generic and project-agnostic — works with any database and any table.
Library          DatabaseLibrary
Library          Collections
Library          String
Library          BuiltIn
Resource         DatabaseCRUD.robot


*** Keywords ***
Validate Table Name
    [Documentation]    Validates that a table name contains only safe characters.
    ...                Prevents SQL injection from dynamic table names.
    [Arguments]    ${table_name}
    
    Should Match Regexp    ${table_name}    ^[a-zA-Z0-9_]+$
    ...    Invalid table name '${table_name}'. Only letters, numbers and underscores are allowed.


Disable Foreign Key Checks
    [Documentation]    Disables foreign key checks in a database-engine-agnostic way.
    [Arguments]    ${driver}=mysql
    
    Run Keyword If    '${driver}' == 'mysql'
    ...    Execute Sql String    SET FOREIGN_KEY_CHECKS=0
    ...    ELSE IF    '${driver}' == 'postgresql'
    ...    Execute Sql String    SET session_replication_role = replica
    ...    ELSE IF    '${driver}' == 'mssql'
    ...    Execute Sql String    EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'


Enable Foreign Key Checks
    [Documentation]    Re-enables foreign key checks in a database-engine-agnostic way.
    [Arguments]    ${driver}=mysql
    
    Run Keyword If    '${driver}' == 'mysql'
    ...    Execute Sql String    SET FOREIGN_KEY_CHECKS=1
    ...    ELSE IF    '${driver}' == 'postgresql'
    ...    Execute Sql String    SET session_replication_role = DEFAULT
    ...    ELSE IF    '${driver}' == 'mssql'
    ...    Execute Sql String    EXEC sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'


Setup Test Table
    [Documentation]    Creates a test table using a given SQL schema.
    [Arguments]    ${create_sql}
    
    Execute Sql String    ${create_sql}
    
    Log    Test table created successfully    level=INFO

    RETURN    True


Drop Test Table
    [Documentation]    Drops a test table by name.
    [Arguments]    ${table_name}
    
    Validate Table Name    ${table_name}
    
    Log    WARNING: Dropping table '${table_name}'    level=WARN
    
    Execute Sql String    DROP TABLE IF EXISTS ${table_name}
    
    Log    Table '${table_name}' dropped    level=INFO
    
    RETURN    True


Drop Multiple Test Tables
    [Documentation]    Drops multiple tables at once.
    [Arguments]    @{table_names}
    
    FOR    ${table}    IN    @{table_names}
        Drop Test Table    ${table}
    END

    RETURN    True


Cleanup Test Record
    [Documentation]    Deletes a specific record from any table using a where clause.
    [Arguments]    ${table_name}    ${where_clause}
    
    Validate Table Name    ${table_name}
    
    Delete Record From Table    ${table_name}    ${where_clause}

    RETURN    True


Cleanup Test Table
    [Documentation]    Truncates a table — removes all data but keeps the structure.
    [Arguments]    ${table_name}    ${driver}=mysql
    
    Validate Table Name    ${table_name}
    
    Disable Foreign Key Checks    ${driver}
    Execute Sql String    TRUNCATE TABLE ${table_name}
    Enable Foreign Key Checks    ${driver}
    
    Log    Table '${table_name}' truncated    level=INFO

    RETURN    True


Cleanup Multiple Test Tables
    [Documentation]    Truncates multiple tables at once.
    [Arguments]    ${driver}=mysql    @{table_names}
    
    Disable Foreign Key Checks    ${driver}
    
    FOR    ${table}    IN    @{table_names}
        Validate Table Name    ${table}
        Execute Sql String    TRUNCATE TABLE ${table}
        Log    Table '${table}' truncated    level=DEBUG
    END
    
    Enable Foreign Key Checks    ${driver}

    RETURN    True