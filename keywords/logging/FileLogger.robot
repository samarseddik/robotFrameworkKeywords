*** Settings ***
Documentation    Reusable keywords for log file management.
...              Handles creation, writing, archiving, and exporting of log files.
...              Generic and project-agnostic — works with any project.
Library          OperatingSystem
Library          DateTime
Library          Collections
Library          String
Library          BuiltIn

*** Keywords ***
Create Log File
    [Documentation]    Creates a new log file with a header.
    [Arguments]    ${log_path}    ${file_name}    ${header}=Robot Framework Execution Log
    
    ${full_path}=    Get Log File Path    ${log_path}    ${file_name}
    
    Run Keyword If    not os.path.exists('${log_path}')
    ...    Create Directory    ${log_path}
    
    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    
    ${content}=    Catenate    SEPARATOR=\n
    ...    ================================================
    ...    ${header}
    ...    Created: ${timestamp}
    ...    ================================================\n
    
    Create File    ${full_path}    ${content}
    
    Log    Log file created: ${full_path}    level=INFO
    
    RETURN    ${full_path}


Append To Log File
    [Documentation]    Appends a line to an existing log file.
    [Arguments]    ${log_path}    ${file_name}    ${message}
    
    ${full_path}=    Get Log File Path    ${log_path}    ${file_name}
    
    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    
    ${line}=    Set Variable    [${timestamp}] ${message}\n
    
    Append To File    ${full_path}    ${line}


Get Log File Path
    [Documentation]    Returns the full path of a log file.
    [Arguments]    ${log_path}    ${file_name}
    
    ${full_path}=    Set Variable    ${log_path}/${file_name}
    
    RETURN    ${full_path}


Validate Log File
    [Documentation]    Checks that a log file exists and is not empty.
    [Arguments]    ${log_path}    ${file_name}
    
    ${full_path}=    Get Log File Path    ${log_path}    ${file_name}
    
    File Should Exist    ${full_path}
    ...    Log file not found: ${full_path}
    
    ${size}=    Get File Size    ${full_path}
    
    Should Be True    ${size} > 0
    ...    Log file is empty: ${full_path}
    
    Log    Log file validated: ${full_path}    level=INFO
    
    RETURN    True


Get Log File Size
    [Documentation]    Returns the size of a log file in bytes.
    [Arguments]    ${log_path}    ${file_name}
    
    ${full_path}=    Get Log File Path    ${log_path}    ${file_name}
    
    File Should Exist    ${full_path}
    
    ${size}=    Get File Size    ${full_path}
    
    Log    Log file size: ${size} bytes    level=INFO
    
    RETURN    ${size}

Archive Log File
    [Documentation]    Moves a log file to an archive folder with timestamp.
    [Arguments]    ${log_path}    ${file_name}
    
    ${full_path}=    Get Log File Path    ${log_path}    ${file_name}
    
    File Should Exist    ${full_path}
    
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${archive_path}=    Set Variable    ${log_path}/archive
    
    Create Directory    ${archive_path}
    
    ${name}=    Fetch From Left    ${file_name}    .
    ${ext}=     Fetch From Right   ${file_name}    .
    ${archived_file}=    Set Variable    ${archive_path}/${name}_${timestamp}.${ext}
    
    Move File    ${full_path}    ${archived_file}
    
    Log    Log file archived to: ${archived_file}    level=INFO
    
    RETURN    ${archived_file}


Backup Log File
    [Documentation]    Creates a copy of a log file.
    [Arguments]    ${log_path}    ${file_name}
    
    ${full_path}=    Get Log File Path    ${log_path}    ${file_name}
    
    File Should Exist    ${full_path}
    
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${backup_path}=    Set Variable    ${log_path}/backup
    
    Create Directory    ${backup_path}
    
    ${name}=    Fetch From Left    ${file_name}    .
    ${ext}=     Fetch From Right   ${file_name}    .
    ${backup_file}=    Set Variable    ${backup_path}/${name}_backup_${timestamp}.${ext}
    
    Copy File    ${full_path}    ${backup_file}
    
    Log    Log file backed up to: ${backup_file}    level=INFO
    
    RETURN    ${backup_file}


Delete Old Logs
    [Documentation]    Deletes log files older than a specified number of days.
    [Arguments]    ${log_path}    ${days}=7
    
    ${files}=    List Files In Directory    ${log_path}    *.log
    
    ${deleted_count}=    Set Variable    ${0}
    
    FOR    ${file}    IN    @{files}
        ${file_path}=    Set Variable    ${log_path}/${file}
        ${modified}=    Get Modified Time    ${file_path}    epoch
        ${now}=    Get Current Date    result_format=epoch
        ${age_days}=    Evaluate    (${now} - ${modified}) / 86400
        
        Run Keyword If    ${age_days} > ${days}
        ...    Remove File    ${file_path}
        Run Keyword If    ${age_days} > ${days}
        ...    Log    Deleted old log: ${file_path}    level=INFO
        
        ${deleted_count}=    Evaluate    ${deleted_count} + 1
    END
    
    Log    Deleted ${deleted_count} old log files from ${log_path}    level=INFO
    
    RETURN    ${deleted_count}


Export Log To JSON
    [Documentation]    Converts a log file to JSON format.
    [Arguments]    ${log_path}    ${file_name}
    
    ${full_path}=    Get Log File Path    ${log_path}    ${file_name}
    
    File Should Exist    ${full_path}
    
    ${content}=    Get File    ${full_path}
    ${lines}=      Split To Lines    ${content}
    
    ${entries}=    Create List
    
    FOR    ${line}    IN    @{lines}
        ${is_entry}=    Run Keyword And Return Status
        ...    Should Match Regexp    ${line}    ^\\[\\d{4}-\\d{2}-\\d{2}
        
        Run Keyword If    ${is_entry}
        ...    Append To List    ${entries}    {"entry": "${line}"}
    END
    
    ${json_name}=    Set Variable    ${file_name.replace('.log', '.json')}
    ${json_path}=    Get Log File Path    ${log_path}    ${json_name}
    ${json_content}=    Evaluate    __import__('json').dumps($entries, indent=2)
    
    Create File    ${json_path}    ${json_content}
    
    Log    Log exported to JSON: ${json_path}    level=INFO
    
    RETURN    ${json_path}


Export Log To CSV
    [Documentation]    Converts a log file to CSV format.
    [Arguments]    ${log_path}    ${file_name}
    
    ${full_path}=    Get Log File Path    ${log_path}    ${file_name}
    
    File Should Exist    ${full_path}
    
    ${content}=    Get File    ${full_path}
    ${lines}=      Split To Lines    ${content}
    
    ${csv_name}=    Set Variable    ${file_name.replace('.log', '.csv')}
    ${csv_path}=    Get Log File Path    ${log_path}    ${csv_name}
    
    Create File    ${csv_path}    timestamp,message\n
    
    FOR    ${line}    IN    @{lines}
        ${is_entry}=    Run Keyword And Return Status
        ...    Should Match Regexp    ${line}    ^\\[\\d{4}-\\d{2}-\\d{2}
        
        Run Keyword If    ${is_entry}
        ...    Append To File    ${csv_path}    "${line}"\n
    END
    
    Log    Log exported to CSV: ${csv_path}    level=INFO
    
    RETURN    ${csv_path}


Generate Execution Report
    [Documentation]    Creates a summary report from all log files in the log path.
    [Arguments]    ${log_path}    ${report_name}=execution_report.txt
    
    ${report_path}=    Get Log File Path    ${log_path}    ${report_name}
    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    
    ${files}=    List Files In Directory    ${log_path}    *.log
    
    ${content}=    Catenate    SEPARATOR=\n
    ...    ================================================
    ...    EXECUTION REPORT
    ...    Generated: ${timestamp}
    ...    ================================================\n
    
    Create File    ${report_path}    ${content}
    
    FOR    ${file}    IN    @{files}
        ${file_path}=    Set Variable    ${log_path}/${file}
        ${file_content}=    Get File    ${file_path}
        Append To File    ${report_path}    \n--- ${file} ---\n
        Append To File    ${report_path}    ${file_content}\n
    END
    
    Log    Execution report generated: ${report_path}    level=INFO
    
    RETURN    ${report_path}


Clear Log File
    [Documentation]    Empties a log file without deleting it.
    [Arguments]    ${log_path}    ${file_name}
    
    ${full_path}=    Get Log File Path    ${log_path}    ${file_name}
    
    File Should Exist    ${full_path}
    
    Create File    ${full_path}    ${EMPTY}
    
    Log    Log file cleared: ${full_path}    level=INFO
    
    RETURN    True


