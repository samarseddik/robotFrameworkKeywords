*** Settings ***
Documentation    Reusable keywords for database connections and session management.
...              Part of the Keyword-Driven Testing strategy.
Library          DatabaseLibrary
Library          Collections
Library          String
Library          BuiltIn

*** Variables ***
${DB_CONNECTION}     ${None}
${DB_HOST}           localhost
${DB_PORT}           5432
${DB_NAME}           test_db
${DB_USER}           test_user
${DB_PASSWORD}       test_password
${DB_DRIVER}         postgresql
${CONNECTION_TIMEOUT}    30



*** Keywords ***
Connect To Database With Config
    [Documentation]    Establishes a database connection using configuration parameters.
    ...                This keyword creates a reusable database connection that can be used
    ...                by other keywords for CRUD operations.
    [Arguments]    ${host}=${DB_HOST}    ${port}=${DB_PORT}    ${database}=${DB_NAME}
    ...            ${user}=${DB_USER}    ${password}=${DB_PASSWORD}    ${driver}=${DB_DRIVER}
    ...            ${timeout}=${CONNECTION_TIMEOUT}
    
    ${dbapi_module}=    Get Database API Module    ${driver}

    Log    Connecting to ${driver} database at ${host}:${port}/${database} using module ${dbapi_module}    level=INFO

    Run Keyword If    '${driver}' == 'sqlite'
    ...    Connect To Database    ${dbapi_module}    ${database}
    ...    ELSE
    ...    Connect To Database    ${dbapi_module}    ${database}    ${user}    ${password}    ${host}    ${port}

    Set Suite Variable    ${DB_CONNECTION}    connected
    Log    Database connection established successfully    level=INFO
    
    RETURN    True
    


Get Database API Module
    [Documentation]    Maps database driver names to a DB API module name.
    [Arguments]    ${driver}

    ${dbapi_module}=    Run Keyword If    '${driver}' == 'postgresql'
    ...    Set Variable    psycopg2
    ...    ELSE IF    '${driver}' == 'mysql'
    ...    Set Variable    mysql.connector
    ...    ELSE IF    '${driver}' == 'sqlite'
    ...    Set Variable    sqlite3
    ...    ELSE IF    '${driver}' == 'mssql'
    ...    Set Variable    pyodbc
    ...    ELSE    Fail    Unsupported database driver: ${driver}

    Log    Database API module resolved for ${driver}: ${dbapi_module}    level=DEBUG

    RETURN    ${dbapi_module}


Verify Database Connection
    [Documentation]    Verifies that the database connection is active and responsive.
    ...                Executes a simple query to confirm connectivity.
    
    ${result}=    Query    SELECT 1 AS connection_test
    
    Log    Database connection verified: ${result}    level=INFO
    
    Should Not Be Empty    ${result}    Database connection failed
    
    RETURN    True    


Disconnect From Database
    [Documentation]    Closes the active database connection.
    ...                Should be called in test teardown to ensure proper cleanup.
    
    Run Keyword And Ignore Error    DatabaseLibrary.Disconnect From Database
    
    Set Suite Variable    ${DB_CONNECTION}    ${None}
    
    Log    Database connection closed    level=INFO
    
    RETURN    True
    

Get Database Connection Status
    [Documentation]    Returns the current status of the database connection.
    
    ${status}=    Set Variable If    '${DB_CONNECTION}' == 'connected'    ACTIVE    INACTIVE
    
    Log    Database connection status: ${status}    level=DEBUG
    
    RETURN    ${status}


Configure Database Connection Parameters
    [Documentation]    Allows runtime configuration of database connection parameters.
    [Arguments]    ${host}=${EMPTY}    ${port}=${EMPTY}    ${database}=${EMPTY}
    ...            ${user}=${EMPTY}    ${password}=${EMPTY}    ${driver}=${EMPTY}
    
    Run Keyword If    '${host}' != ''    Set Suite Variable    ${DB_HOST}    ${host}
    Run Keyword If    '${port}' != ''    Set Suite Variable    ${DB_PORT}    ${port}
    Run Keyword If    '${database}' != ''    Set Suite Variable    ${DB_NAME}    ${database}
    Run Keyword If    '${user}' != ''    Set Suite Variable    ${DB_USER}    ${user}
    Run Keyword If    '${password}' != ''    Set Suite Variable    ${DB_PASSWORD}    ${password}
    Run Keyword If    '${driver}' != ''    Set Suite Variable    ${DB_DRIVER}    ${driver}
    
    Log    Database connection parameters configured    level=INFO
