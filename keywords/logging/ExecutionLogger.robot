*** Settings ***
Documentation    Reusable keywords for execution logging.
...              Handles suite, test, and keyword level logging with timestamps.
...              Generic and project-agnostic — works with any project.
Library          OperatingSystem
Library          DateTime
Library          Collections
Library          String
Library          BuiltIn
Resource         fileLogger.robot

*** Keywords ***
Format Timestamp
    [Documentation]    Returns current date and time as a formatted string.
    [Arguments]    ${format}=%Y-%m-%d %H:%M:%S
    
    ${timestamp}=    Get Current Date    result_format=${format}
    
    RETURN    ${timestamp}


Store Start Time
    [Documentation]    Stores the start time of an execution in a suite variable.
    [Arguments]    ${variable_name}=EXECUTION_START_TIME
    
    ${start_time}=    Get Current Date    result_format=epoch
    
    Set Suite Variable    ${${variable_name}}    ${start_time}
    
    RETURN    ${start_time}


Store End Time
    [Documentation]    Stores the end time of an execution in a suite variable.
    [Arguments]    ${variable_name}=EXECUTION_END_TIME
    
    ${end_time}=    Get Current Date    result_format=epoch
    
    Set Suite Variable    ${${variable_name}}    ${end_time}
    
    RETURN    ${end_time}


Get Execution Start Time
    [Documentation]    Returns the stored execution start time.
    [Arguments]    ${variable_name}=EXECUTION_START_TIME
    
    RETURN    ${${variable_name}}


Get Execution End Time
    [Documentation]    Returns the stored execution end time.
    [Arguments]    ${variable_name}=EXECUTION_END_TIME
    
    RETURN    ${${variable_name}}


Calculate Execution Duration
    [Documentation]    Calculates duration in seconds between start and end time.
    [Arguments]    ${start_time}    ${end_time}
    
    ${duration}=    Evaluate    round(${end_time} - ${start_time}, 2)
    
    RETURN    ${duration}


Log Duration
    [Documentation]    Logs the execution duration to a log file.
    [Arguments]    ${log_path}    ${file_name}    ${label}    ${duration}
    
    ${message}=    Set Variable    DURATION | ${label} | ${duration}s
    Append To Log File    ${log_path}    ${file_name}    ${message}


Start Execution Logging
    [Documentation]    Initializes the execution log file and stores start time.
    [Arguments]    ${log_path}    ${file_name}=execution.log
    
    Create Log File    ${log_path}    ${file_name}    Robot Framework Execution Log
    
    Store Start Time
    
    ${timestamp}=    Format Timestamp
    ${message}=    Set Variable    INFO | Execution logging started at ${timestamp}
    Append To Log File    ${log_path}    ${file_name}    ${message}
    
    RETURN    ${file_name}



Stop Execution Logging
    [Documentation]    Stores end time and logs execution stopped message.
    [Arguments]    ${log_path}    ${file_name}=execution.log
    
    Store End Time
    
    ${start}=    Get Execution Start Time
    ${end}=      Get Execution End Time
    ${duration}=    Calculate Execution Duration    ${start}    ${end}
    
    ${timestamp}=    Format Timestamp
    ${message}=    Set Variable    INFO | Execution logging stopped at ${timestamp} | Total duration: ${duration}s
    Append To Log File    ${log_path}    ${file_name}    ${message}



Enable Logging
    [Documentation]    Enables logging by setting a suite variable flag.
    
    Set Suite Variable    ${LOGGING_ENABLED}    True
    
    Log    Logging enabled    level=INFO


Disable Logging
    [Documentation]    Disables logging by setting a suite variable flag.
    
    Set Suite Variable    ${LOGGING_ENABLED}    False
    
    Log    Logging disabled    level=INFO


Set Log Level
    [Documentation]    Sets the current log level.
    [Arguments]    ${level}=INFO
    
    Should Match Regexp    ${level}    ^(DEBUG|INFO|WARNING|ERROR|CRITICAL)$
    ...    Invalid log level '${level}'. Valid levels: DEBUG, INFO, WARNING, ERROR, CRITICAL
    
    Set Suite Variable    ${CURRENT_LOG_LEVEL}    ${level}
    
    Log    Log level set to: ${level}    level=INFO


Get Log Level
    [Documentation]    Returns the current log level.
    
    ${level}=    Set Variable If    '${CURRENT_LOG_LEVEL}' != '${None}'    ${CURRENT_LOG_LEVEL}    INFO
    
    RETURN    ${level}


Clear Execution Log
    [Documentation]    Clears the execution log file.
    [Arguments]    ${log_path}    ${file_name}=execution.log
    
    Clear Log File    ${log_path}    ${file_name}
    
    Log    Execution log cleared    level=INFO
    RETURN    True


Archive Execution Log
    [Documentation]    Archives the execution log file.
    [Arguments]    ${log_path}    ${file_name}=execution.log
    
    ${archived}=    Archive Log File    ${log_path}    ${file_name}
    
    RETURN    ${archived}


Log Suite Setup Start
    [Documentation]    Logs the start of a suite setup.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${suite_name}=${SUITE NAME}
    
    ${message}=    Set Variable    SUITE SETUP START | ${suite_name}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Suite Setup End
    [Documentation]    Logs the end of a suite setup.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${suite_name}=${SUITE NAME}

    ${message}=    Set Variable    SUITE SETUP END | ${suite_name}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Suite Teardown Start
    [Documentation]    Logs the start of a suite teardown.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${suite_name}=${SUITE NAME}
    
    ${message}=    Set Variable    SUITE TEARDOWN START | ${suite_name}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Suite Teardown End
    [Documentation]    Logs the end of a suite teardown.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${suite_name}=${SUITE NAME}
    
    ${message}=    Set Variable    SUITE TEARDOWN END | ${suite_name}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Suite Summary
    [Documentation]    Logs a summary of the suite execution.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${suite_name}=${SUITE NAME}
    ...            ${total}=0    ${passed}=0    ${failed}=0

    ${message}=    Set Variable    SUITE SUMMARY | ${suite_name} | Total: ${total} | Passed: ${passed} | Failed: ${failed} 
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Suite Statistics
    [Documentation]    Logs detailed statistics of the suite execution.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${suite_name}=${SUITE NAME}
    ...            ${total}=0    ${passed}=0    ${failed}=0    ${skipped}=0    ${duration}=0

    ${pass_rate}=    Evaluate    round(${passed} / ${total} * 100, 2) if ${total} > 0 else 0
    ${message}=    Set Variable    SUITE STATS | ${suite_name} | Total: ${total} | Passed: ${passed} | Failed: ${failed} | Skipped: ${skipped} | Pass Rate: ${pass_rate}% | Duration: ${duration}s 
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Test Setup Start
    [Documentation]    Logs the start of a test setup.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${test_name}=${TEST NAME}

    ${message}=    Set Variable    TEST SETUP START | ${test_name}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Test Setup End
    [Documentation]    Logs the end of a test setup.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${test_name}=${TEST NAME}
    
    ${message}=    Set Variable    TEST SETUP END | ${test_name}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Test Teardown Start
    [Documentation]    Logs the start of a test teardown.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${test_name}=${TEST NAME}
    
    ${message}=    Set Variable    TEST TEARDOWN START | ${test_name}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Test Teardown End
    [Documentation]    Logs the end of a test teardown.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${test_name}=${TEST NAME}
    
    ${message}=    Set Variable    TEST TEARDOWN END | ${test_name}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Test Duration
    [Documentation]    Logs the duration of a test case.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${test_name}=${TEST NAME}
    ...            ${duration}=0
    
    ${message}=    Set Variable    TEST DURATION | ${test_name} | ${duration}s
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Test Summary
    [Documentation]    Logs a summary of a test case execution.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${test_name}=${TEST NAME}
    ...            ${status}=PASS    ${duration}=0
    
    ${message}=    Set Variable    TEST SUMMARY | ${test_name} | Status: ${status} | Duration: ${duration}s
    Append To Log File    ${log_path}    ${file_name}    ${message} TEST SUMMARY | ${test_name} | Status: ${status} | Duration: ${duration}s 


Log Test Error
    [Documentation]    Logs an error that occurred during a test case.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${test_name}=${TEST NAME}
    ...            ${error_message}=Unknown error
    
    ${message}=    Set Variable    TEST ERROR | ${test_name} | ${error_message}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Keyword Arguments
    [Documentation]    Logs the arguments passed to a keyword.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${keyword_name}=Unknown
    ...            @{args}
    
    ${args_str}=    Evaluate    ', '.join(str(a) for a in $args)
    ${message}=    Set Variable    KEYWORD ARGS | ${keyword_name} | Args: ${args_str}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Keyword Result
    [Documentation]    Logs the result returned by a keyword.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${keyword_name}=Unknown
    ...            ${result}=${None}

    ${message}=    Set Variable    KEYWORD RESULT | ${keyword_name} | Result: ${result}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Keyword Success
    [Documentation]    Logs a successful keyword execution.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${keyword_name}=Unknown
    
    ${message}=    Set Variable    KEYWORD SUCCESS | ${keyword_name}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Keyword Failure
    [Documentation]    Logs a failed keyword execution.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${keyword_name}=Unknown
    ...            ${error_message}=Unknown error
    
    ${message}=    Set Variable    KEYWORD FAILURE | ${keyword_name} | ${error_message}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Keyword Duration
    [Documentation]    Logs the duration of a keyword execution.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${keyword_name}=Unknown
    ...            ${duration}=0
    
    ${message}=    Set Variable    KEYWORD DURATION | ${keyword_name} | ${duration}s
    Append To Log File    ${log_path}    ${file_name}    ${message}


Capture Keyword Error Message
    [Documentation]    Runs a keyword and captures any error message without failing.
    [Arguments]    ${keyword_name}    @{args}
    
    ${status}    ${error}=    Run Keyword And Ignore Error    ${keyword_name}    @{args}
    
    RETURN    ${error}


Get Execution Status
    [Documentation]    Returns the current test execution status.
    
    RETURN    ${PREV TEST STATUS}


Log Execution Status
    [Documentation]    Logs the current execution status.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${test_name}=${TEST NAME}
    
    ${status}=    Get Execution Status
    ${message}=    Set Variable    EXECUTION STATUS | ${test_name} | ${status} 
    Append To Log File    ${log_path}    ${file_name}    ${message}


Update Execution Status
    [Documentation]    Logs an updated execution status with a custom message.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${status}=PASS
    ...            ${message}=${EMPTY}
    
    
    ${log_message}=    Set Variable    STATUS UPDATE | ${status} | ${message} 
    Append To Log File    ${log_path}    ${file_name}    ${log_message}


Log Failure Reason
    [Documentation]    Logs the reason for a test failure.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${reason}=Unknown reason
    
    ${message}=    Set Variable    FAILURE REASON | ${reason} 
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Pass Message
    [Documentation]    Logs a custom pass message.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${message}=Test passed
    
    ${log_message}=    Set Variable    PASS | ${message} 
    Append To Log File    ${log_path}    ${file_name}    ${log_message}


Log Skipped Test
    [Documentation]    Logs a skipped test case.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${test_name}=${TEST NAME}
    ...            ${reason}=No reason provided
    
    ${message}=    Set Variable    SKIPPED | ${test_name} | Reason: ${reason}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Critical Failure
    [Documentation]    Logs a critical failure that stops execution.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${message}=Critical failure
    
    ${log_message}=    Set Variable    CRITICAL FAILURE | ${message}
    Append To Log File    ${log_path}    ${file_name}    ${log_message}
    
    Fatal Error    ${message}


Log Debug Message
    [Documentation]    Logs a debug message.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${message}=${EMPTY}
    
    ${level}=    Get Log Level
    
    Run Keyword If    '${level}' == 'DEBUG'
    ...    Append To Log File    ${log_path}    ${file_name}    DEBUG | ${message}


Log Error Message
    [Documentation]    Logs an error message.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${message}=${EMPTY}
    
    ${log_message}=    Set Variable    ERROR | ${message}
    Append To Log File    ${log_path}    ${file_name}    ${log_message}


Log Critical Message
    [Documentation]    Logs a critical message.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${message}=${EMPTY}
    
    ${log_message}=    Set Variable    CRITICAL | ${message}
    Append To Log File    ${log_path}    ${file_name}    ${log_message}


Log Test Step
    [Documentation]    Logs a test step message.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${step}=${EMPTY}
    
    ${message}=    Set Variable    STEP | ${step}
    Append To Log File    ${log_path}    ${file_name}    ${message}


Log Validation Result
    [Documentation]    Logs a validation step message.
    [Arguments]    ${log_path}    ${file_name}=execution.log    ${step}=${EMPTY}
    ...            ${expected}=${EMPTY}    ${actual}=${EMPTY}
    
    ${message}=    Set Variable    VALIDATION | ${step} | Expected: ${expected} | Actual: ${actual}
    Append To Log File    ${log_path}    ${file_name}    ${message}