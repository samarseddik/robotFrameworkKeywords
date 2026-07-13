*** Settings ***
Documentation    Reusable keywords for error logging.
...              Handles detailed error capturing, exceptions, assertions, and recovery.
...              Generic and project-agnostic — works with any project.
Library          OperatingSystem
Library          DateTime
Library          Collections
Library          String
Library          BuiltIn
Resource         FileLogger.robot

*** Keywords ***
Log Error Details
    [Documentation]    Logs a detailed error with error type and message.
    [Arguments]    ${log_path}    ${file_name}=errors.log    ${error_type}=UnknownError
    ...            ${error_message}=No message provided

    ${message}=    Set Variable    ERROR DETAILS | Type: ${error_type} | Message: ${error_message}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Exception
    [Documentation]    Logs a full exception including stack trace.
    [Arguments]    ${log_path}    ${file_name}=errors.log    ${exception_type}=Exception
    ...            ${exception_message}=No message provided    ${stack_trace}=No stack trace available

    ${message}=    Set Variable    EXCEPTION | Type: ${exception_type} | Message: ${exception_message} | Stack Trace: ${stack_trace}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Assertion Error
    [Documentation]    Logs a failed assertion with expected and actual values.
    [Arguments]    ${log_path}    ${file_name}=errors.log    ${assertion}=Unknown assertion
    ...            ${expected}=${EMPTY}    ${actual}=${EMPTY}

    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${message}=    Set Variable    ASSERTION ERROR | ${assertion} | Expected: ${expected} | Actual: ${actual} 
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Connection Error
    [Documentation]    Logs a database connection error with host and database info.
    [Arguments]    ${log_path}    ${file_name}=errors.log    ${host}=${EMPTY}
    ...            ${database}=${EMPTY}    ${error_message}=Connection failed

    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${message}=    Set Variable    CONNECTION ERROR | Host: ${host} | Database: ${database} | Message: ${error_message} | ${timestamp}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Timeout Error
    [Documentation]    Logs a timeout error with operation and duration info.
    [Arguments]    ${log_path}    ${file_name}=errors.log    ${operation}=Unknown operation
    ...            ${timeout}=0    ${unit}=s

    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${message}=    Set Variable    TIMEOUT ERROR | Operation: ${operation} | Timeout: ${timeout}${unit} | ${timestamp}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Critical Error
    [Documentation]    Logs a critical error.
    [Arguments]    ${log_path}    ${file_name}=errors.log    ${error_message}=Critical error occurred

    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${message}=    Set Variable    CRITICAL ERROR | ${error_message} | ${timestamp}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Warning Message
    [Documentation]    Logs a warning message without stopping execution.
    [Arguments]    ${log_path}    ${file_name}=errors.log    ${warning_message}=No warning message provided

    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${message}=    Set Variable    WARNING | ${warning_message} | ${timestamp}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Error Summary
    [Documentation]    Logs a summary of all errors collected at the end of execution.
    [Arguments]    ${log_path}    ${file_name}=errors.log    ${total_errors}=0
    ...            ${total_warnings}=0    ${suite_name}=${SUITE NAME}

    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${message}=    Set Variable    ERROR SUMMARY | Suite: ${suite_name} | Total Errors: ${total_errors} | Total Warnings: ${total_warnings} | ${timestamp}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Capture And Log Error
    [Documentation]    Runs a keyword, captures any error without failing, and logs it.
    [Arguments]    ${log_path}    ${file_name}=errors.log    ${keyword_name}=Unknown
    ...            @{args}

    ${status}    ${error}=    Run Keyword And Ignore Error    ${keyword_name}    @{args}

    Run Keyword If    '${status}' == 'FAIL'
    ...    Log Error Details    ${log_path}    ${file_name}    CapturedError    ${error}

    RETURN    ${status}    ${error}


Log Recovery Action
    [Documentation]    Logs the recovery action taken after an error.
    [Arguments]    ${log_path}    ${file_name}=errors.log    ${error_message}=Unknown error
    ...            ${recovery_action}=No recovery action provided    ${status}=SUCCESS

    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${message}=    Set Variable    RECOVERY ACTION | Error: ${error_message} | Action: ${recovery_action} | Status: ${status} | ${timestamp}
    Append To Log File    ${log_path}    ${file_name}    ${message}