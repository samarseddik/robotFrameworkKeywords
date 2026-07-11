*** Settings ***
Documentation    Reusable keywords for CRUD operations (Create, Read, Update, Delete).
...              Provides high-level business keywords for database manipulation.
Library          DatabaseLibrary
Library          Collections
Library          String
Library          BuiltIn

*** Keywords ***
Create Record In Table
    [Documentation]    Creates a new record in the specified table.
    ...                This keyword accepts a dictionary of column:value pairs
    ...                and generates an INSERT query.
    [Arguments]    ${table_name}    &{data}
    
    Log    Creating record in table '${table_name}' with data: ${data}    level=INFO
    
    ${columns}=    Get Dictionary Keys    ${data}
    ${column_list}=    Evaluate    ','.join($columns)
    ${values_list}=    Create List
    
    FOR    ${column}    IN    @{columns}
        ${value}=    Get From Dictionary    ${data}    ${column}
        Append To List    ${values_list}    '${value}'
    END
    
    ${values_str}=    Evaluate    ','.join($values_list)
    ${query}=    Set Variable    INSERT INTO ${table_name} (${column_list}) VALUES (${values_str})
    
    Log    Executing query: ${query}    level=DEBUG
    
    Execute Sql String    ${query}
    
    Log    Record created successfully in ${table_name}    level=INFO
    
    RETURN    True


Read Records From Table
    [Documentation]    Retrieves records from a table based on optional WHERE conditions.
    ...                Returns a list of dictionaries representing the records.
    [Arguments]    ${table_name}    ${where_clause}=${EMPTY}    ${order_by}=${EMPTY}    ${limit}=${EMPTY}    ${driver}=mysql
    
    ${query}=    Set Variable    SELECT * FROM ${table_name}

    Run Keyword If    '${driver}' == 'mssql' and '${limit}' != ''
    ...    Set Test Variable    ${query}    SELECT TOP ${limit} * FROM ${table_name}
    ...    ELSE
    ...    Set Test Variable    ${query}    SELECT * FROM ${table_name}
    
    Run Keyword If    '${where_clause}' != ''    Set Test Variable    ${query}
    ...              ${query} WHERE ${where_clause}
    
    Run Keyword If    '${order_by}' != ''    Set Test Variable    ${query}
    ...              ${query} ORDER BY ${order_by}
    
    Run Keyword If    '${limit}' != '' and '${driver}' != 'mssql'    Set Test Variable    ${query}
    ...              ${query} LIMIT ${limit}
    
    Log    Executing query: ${query}    level=DEBUG
    
    ${result}=    Query    ${query}
    
    Log    Retrieved ${result.__len__()} records from ${table_name}    level=INFO
    
    RETURN    ${result}


Read Record By Id
    [Documentation]    Retrieves a single record by its primary key (ID).
    [Arguments]    ${table_name}    ${id}    ${id_column}=id
    
    ${where_clause}=    Set Variable    ${id_column} = ${id}
    
    ${result}=    Read Records From Table    ${table_name}    ${where_clause}    ${EMPTY}    1
    
    ${record}=    Set Variable If    len($result) > 0    ${result[0]}    ${None}
    
    Log    Retrieved record with ${id_column}=${id}: ${record}    level=DEBUG
    
    RETURN    ${record}


Update Record In Table
    [Documentation]    Updates one or more records in a table based on WHERE conditions.
    ...                Accepts a dictionary of column:value pairs to update.
    [Arguments]    ${table_name}    ${where_clause}    &{data}
    
    Log    Updating records in table '${table_name}' where ${where_clause}    level=INFO
    
    ${set_clause}=    Create List
    ${columns}=    Get Dictionary Keys    ${data}
    
    FOR    ${column}    IN    @{columns}
        ${value}=    Get From Dictionary    ${data}    ${column}
        Append To List    ${set_clause}    ${column}='${value}'
    END
    
    ${set_str}=    Evaluate    ', '.join($set_clause)
    ${query}=    Set Variable    UPDATE ${table_name} SET ${set_str} WHERE ${where_clause}
    
    Log    Executing query: ${query}    level=DEBUG
    
    Execute Sql String    ${query}
    
    Log    Records updated successfully in ${table_name}    level=INFO

    RETURN    True
    


Update Record By Id
    [Documentation]    Updates a single record identified by its primary key.
    [Arguments]    ${table_name}    ${id}    ${id_column}=id    &{data}
    
    ${where_clause}=    Set Variable    ${id_column} = ${id}
    
    Update Record In Table    ${table_name}    ${where_clause}    &{data}

    RETURN    True


Delete Record From Table
    [Documentation]    Deletes records from a table based on WHERE conditions.
    ...                This is a dangerous operation - use with caution!
    [Arguments]    ${table_name}    ${where_clause}
    
    Log    WARNING: Deleting records from '${table_name}' where ${where_clause}    level=WARN
    
    ${query}=    Set Variable    DELETE FROM ${table_name} WHERE ${where_clause}
    
    Log    Executing query: ${query}    level=DEBUG
    
    Execute Sql String    ${query}
    
    Log    Records deleted successfully from ${table_name}    level=INFO
    
    RETURN    True


Delete Record By Id
    [Documentation]    Deletes a single record identified by its primary key.
    [Arguments]    ${table_name}    ${id}    ${id_column}=id
    
    ${where_clause}=    Set Variable    ${id_column} = ${id}
    
    Delete Record From Table    ${table_name}    ${where_clause}
    
    RETURN    True


Count Records In Table
    [Documentation]    Returns the count of records in a table, optionally filtered by WHERE clause.
    [Arguments]    ${table_name}    ${where_clause}=${EMPTY}
    
    ${query}=    Set Variable    SELECT COUNT(*) as record_count FROM ${table_name}
    
    Run Keyword If    '${where_clause}' != ''    Set Test Variable    ${query}
    ...              ${query} WHERE ${where_clause}
    
    Log    Executing query: ${query}    level=DEBUG
    
    ${result}=    Query    ${query}
    
    ${count}=    Set Variable If    len($result) > 0    ${result[0][0]}    0
    
    Log    Found ${count} records in ${table_name}    level=INFO
    
    RETURN    ${count}


Execute Custom Query
    [Documentation]    Executes a custom SQL query and returns the results.
    ...                Use this for complex queries not covered by other keywords.
    [Arguments]    ${query}
    
    Log    Executing custom query: ${query}    level=DEBUG
    
    ${result}=    Query    ${query}
    
    Log    Query executed successfully, ${result.__len__()} rows returned    level=INFO
    
    RETURN    ${result}


Execute Custom Query Without Result
    [Documentation]    Executes a custom SQL query without expecting a result set.
    ...                Useful for DDL statements like CREATE TABLE, ALTER TABLE, etc.
    [Arguments]    ${query}
    
    Log    Executing query: ${query}    level=DEBUG
    
    Execute Sql String    ${query}
    
    Log    Query executed successfully    level=INFO
    
    RETURN    True
