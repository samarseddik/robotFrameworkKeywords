*** Settings ***
Documentation    Reusable keywords for database query logging.
...              Handles logging of SQL queries, results, and transactions.
...              Generic and project-agnostic — works with any project.
Library          OperatingSystem
Library          DateTime
Library          Collections
Library          String
Library          BuiltIn
Resource         FileLogger.robot

*** Keywords ***
Log Database Query
    [Documentation]    Logs a SQL query with timestamp.
    [Arguments]    ${log_path}    ${file_name}=queries.log    ${query}=${EMPTY}
    
    ${message}=    Set Variable    QUERY | ${query}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Query Result
    [Documentation]    Logs the result of a SQL query.
    [Arguments]    ${log_path}    ${file_name}=queries.log    ${query}=${EMPTY}
    ...            ${result}=${None}    ${row_count}=0
    
    ${message}=    Set Variable    QUERY RESULT | ${query} | Rows: ${row_count}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Query Duration
    [Documentation]    Logs how long a query took to execute.
    [Arguments]    ${log_path}    ${file_name}=queries.log    ${query}=${EMPTY}
    ...            ${duration}=0
    
    ${message}=    Set Variable    QUERY DURATION | ${query} | ${duration}s
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Query Success
    [Documentation]    Logs a successful query execution.
    [Arguments]    ${log_path}    ${file_name}=queries.log    ${query}=${EMPTY}
    
    ${message}=    Set Variable    QUERY SUCCESS | ${query}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Query Failure
    [Documentation]    Logs a failed query execution with error message.
    [Arguments]    ${log_path}    ${file_name}=queries.log    ${query}=${EMPTY}
    ...            ${error_message}=Unknown error
    
    ${message}=    Set Variable    QUERY FAILURE | ${query} | Error: ${error_message}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Query Parameters
    [Documentation]    Logs the parameters passed to a query.
    [Arguments]    ${log_path}    ${file_name}=queries.log    ${query}=${EMPTY}
    ...            &{params}
    
    ${params_str}=    Evaluate    ', '.join(f'{k}={v}' for k,v in $params.items())
    ${message}=    Set Variable    QUERY PARAMS | ${query} | Params: ${params_str}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Connection Details
    [Documentation]    Logs database connection details.
    [Arguments]    ${log_path}    ${file_name}=queries.log    ${host}=${EMPTY}
    ...            ${port}=${EMPTY}    ${database}=${EMPTY}    ${driver}=${EMPTY}
    
    ${message}=    Set Variable    CONNECTION | Host: ${host} | Port: ${port} | Database: ${database} | Driver: ${driver}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Transaction Start
    [Documentation]    Logs when a database transaction starts.
    [Arguments]    ${log_path}    ${file_name}=queries.log    ${transaction_id}=${EMPTY}
    
    ${message}=    Set Variable    TRANSACTION START | ID: ${transaction_id}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Transaction End
    [Documentation]    Logs when a database transaction ends successfully.
    [Arguments]    ${log_path}    ${file_name}=queries.log    ${transaction_id}=${EMPTY}
    ...            ${duration}=0
    
    ${message}=    Set Variable    TRANSACTION END | ID: ${transaction_id} | Duration: ${duration}s
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Transaction Rollback
    [Documentation]    Logs when a database transaction is rolled back.
    [Arguments]    ${log_path}    ${file_name}=queries.log    ${transaction_id}=${EMPTY}
    ...            ${reason}=Unknown reason
    
    ${message}=    Set Variable    TRANSACTION ROLLBACK | ID: ${transaction_id} | Reason: ${reason}
    Append To Log File    ${log_path}    ${file_name}    ${message}