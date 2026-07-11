*** Settings ***
Documentation    Reusable keywords for database validation and assertions.
...              Provides business-level validation keywords for test verification.
Library          DatabaseLibrary
Library          Collections
Library          String
Library          BuiltIn
Resource         DatabaseCRUD.robot


*** Keywords ***
Verify Record Exists
    [Documentation]    Verifies that a record exists in the database table.
    [Arguments]    ${table_name}    ${where_clause}
    
    ${count}=    Execute Custom Query    SELECT COUNT(*) as cnt FROM ${table_name} WHERE ${where_clause}
    
    ${record_count}=    Set Variable    ${count[0][0]}
    
    Should Be True    ${record_count} > 0    Record not found with condition: ${where_clause}
    
    Log    Record verified to exist in ${table_name}    level=INFO
    
    RETURN    True


Verify Record Does Not Exist
    [Documentation]    Verifies that a record does NOT exist in the database table.
    [Arguments]    ${table_name}    ${where_clause}
    
    ${count}=    Execute Custom Query    SELECT COUNT(*) as cnt FROM ${table_name} WHERE ${where_clause}
    
    ${record_count}=    Set Variable    ${count[0][0]}
    
    Should Be Equal As Numbers    ${record_count}    0
    ...    Record should not exist but found ${record_count} matching records
    
    Log    Verified that record does not exist in ${table_name}    level=INFO

    RETURN    True


Verify Column Value
    [Documentation]    Verifies that a specific column has an expected value in a record.
    [Arguments]    ${table_name}    ${where_clause}    ${column_name}    ${expected_value}
    
    ${result}=    Execute Custom Query
    ...    SELECT ${column_name} FROM ${table_name} WHERE ${where_clause}
    
    Should Not Be Empty    ${result}    No record found with condition: ${where_clause}
    
    ${actual_value}=    Set Variable    ${result[0][0]}
    
    Should Be Equal As Strings    ${actual_value}    ${expected_value}
    ...    Column '${column_name}' value mismatch. Expected: ${expected_value}, Got: ${actual_value}
    
    Log    Column '${column_name}' verified with value: ${expected_value}    level=INFO

    RETURN    True


Verify Multiple Column Values
    [Documentation]    Verifies multiple column values in a single record.
    ...                Accepts a dictionary of column_name:expected_value pairs.
    [Arguments]    ${table_name}    ${where_clause}    &{expected_values}
    
    ${columns}=    Get Dictionary Keys    ${expected_values}
    ${column_list}=    Evaluate    ','.join($columns)
    
    ${result}=    Execute Custom Query
    ...    SELECT ${column_list} FROM ${table_name} WHERE ${where_clause}
    
    Should Not Be Empty    ${result}    No record found with condition: ${where_clause}
    
    ${index}=    Set Variable    ${0}
    FOR    ${column}    IN    @{columns}
        ${expected_value}=    Get From Dictionary    ${expected_values}    ${column}
        ${actual_value}=    Set Variable    ${result[0][${index}]}
        Should Be Equal As Strings    ${actual_value}    ${expected_value}
        ...    Column '${column}' mismatch. Expected: ${expected_value}, Got: ${actual_value}
        ${index}=    Evaluate    ${index} + 1
    END
    
    Log    All column values verified successfully    level=INFO
    
    RETURN    True

Verify Table Is Empty
    [Documentation]    Verifies that a table has no records.
    [Arguments]    ${table_name}
    
    ${count}=    Count Records In Table    ${table_name}
    
    Should Be Equal As Numbers    ${count}    0
    ...    Table '${table_name}' should be empty but contains ${count} records
    
    Log    Table '${table_name}' is empty as expected    level=INFO
    
    RETURN    True
    

Verify Table Is Not Empty
    [Documentation]    Verifies that a table contains at least one record.
    [Arguments]    ${table_name}
    
    ${count}=    Count Records In Table    ${table_name}
    
    Should Be True    ${count} > 0    Table '${table_name}' is empty
    
    Log    Table '${table_name}' contains ${count} records    level=INFO
    
    RETURN    True
    


Verify Table Record Count
    [Documentation]    Verifies that a table contains an expected number of records.
    [Arguments]    ${table_name}    ${expected_count}    ${where_clause}=${EMPTY}
    
    ${actual_count}=    Count Records In Table    ${table_name}    ${where_clause}
    
    Should Be Equal As Numbers    ${actual_count}    ${expected_count}
    ...    Expected ${expected_count} records but found ${actual_count}
    
    Log    Table '${table_name}' record count verified: ${actual_count}    level=INFO
    
    RETURN    True
    

Verify Column Exists
    [Documentation]    Verifies that a column exists in a table.
    [Arguments]    ${table_name}    ${column_name}
    
    ${query}=    Set Variable    SELECT column_name FROM information_schema.columns WHERE table_name = '${table_name}' AND column_name = '${column_name}'    
    ${result}=    Execute Custom Query    ${query}
    
    Should Not Be Empty    ${result}
    ...    Column '${column_name}' does not exist in table '${table_name}'
    
    Log    Column '${column_name}' verified to exist in table '${table_name}'    level=INFO
    
    RETURN    True

Verify Unique Constraint
    [Documentation]    Verifies that a column value is unique in the table.
    ...                Ensures no duplicate values exist for the specified column.
    [Arguments]    ${table_name}    ${column_name}    ${value}
    
    ${count}=    Execute Custom Query
    ...    SELECT COUNT(*) as cnt FROM ${table_name} WHERE ${column_name} = '${value}'
    
    ${record_count}=    Set Variable    ${count[0][0]}
    
    Should Be Equal As Numbers    ${record_count}    1
    ...    Expected exactly 1 record with ${column_name}='${value}', found ${record_count}
    
    Log    Unique constraint verified for ${column_name}='${value}'    level=INFO
    
    RETURN    True


Verify Data Type
    [Documentation]    Verifies that a column has the expected data type.
    [Arguments]    ${table_name}    ${column_name}    ${expected_data_type}
    
    ${query}=    Set Variable    SELECT data_type FROM information_schema.columns WHERE table_name = '${table_name}' AND column_name = '${column_name}'
    
    ${result}=    Execute Custom Query    ${query}
    
    Should Not Be Empty    ${result}
    ...    Column '${column_name}' not found in table '${table_name}'
    
    ${actual_data_type}=    Set Variable    ${result[0][0]}
    
    Should Contain    ${actual_data_type}    ${expected_data_type}
    ...    Data type mismatch for ${column_name}. Expected: ${expected_data_type}, Got: ${actual_data_type}
    
    Log    Data type verified for ${column_name}: ${actual_data_type}    level=INFO
    
    RETURN    True

Verify Foreign Key Relationship
    [Documentation]    Verifies that a foreign key relationship exists and is valid.
    [Arguments]    ${parent_table}    ${parent_id}    ${child_table}    ${child_fk_column}    ${fk_value}     ${parent_id_column}=id
    
    ${parent_exists}=    Verify Record Exists    ${parent_table}     ${parent_id_column} = ${parent_id}
    
    ${child_exists}=    Verify Record Exists    ${child_table}    ${child_fk_column} = ${fk_value}
    
    Log    Foreign key relationship verified between ${parent_table} and ${child_table}    level=INFO
    
    RETURN    True
    

