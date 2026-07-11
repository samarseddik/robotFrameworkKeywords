*** Settings ***
Documentation    Reusable SSH utility keywords for connection management,
...              command execution, file transfer, and validation.
...              Generic and project-agnostic.
Library          SSHLibrary
Library          BuiltIn

*** Variables ***
${DEFAULT_SSH_PORT}    22
${DEFAULT_TIMEOUT}     10
${DEFAULT_ALIAS}       default

*** Keywords ***
# =============================================================================
# CONNECTION MANAGEMENT
# =============================================================================

Connect To SSH Server
    [Documentation]    Establishes an SSH connection using password or public key authentication.
    [Arguments]    ${host}
    ...    ${user}
    ...    ${password}=${EMPTY}
    ...    ${key_file}=${EMPTY}
    ...    ${port}=${DEFAULT_SSH_PORT}
    ...    ${timeout}=${DEFAULT_TIMEOUT}
    ...    ${alias}=${DEFAULT_ALIAS}

    Open Connection    ${host}    port=${port}    timeout=${timeout}    alias=${alias}

    IF    '${key_file}' != '${EMPTY}'
        Login With Public Key    ${user}    ${key_file}
    ELSE IF    '${password}' != '${EMPTY}'
        Login    ${user}    ${password}
    ELSE
        Fail    Either password or key_file must be provided.
    END

    ${current_user}=    Execute Command    whoami
    Should Not Be Empty    ${current_user}

    RETURN    ${alias}


Disconnect SSH Session
    [Documentation]    Disconnects a specific SSH session.
    [Arguments]    ${alias}=${DEFAULT_ALIAS}

    Switch Connection    ${alias}
    Close Connection


Disconnect All SSH Sessions
    [Documentation]    Disconnects all active SSH sessions.

    Close All Connections


Switch SSH Session
    [Documentation]    Switches to a specific SSH session.
    [Arguments]    ${alias}

    Switch Connection    ${alias}


# =============================================================================
# COMMAND EXECUTION
# =============================================================================

Execute SSH Command
    [Documentation]    Executes a command and returns stdout.
    [Arguments]    ${command}    ${alias}=${DEFAULT_ALIAS}

    Switch Connection    ${alias}

    ${stdout}=    Execute Command    ${command}

    RETURN    ${stdout}


Execute SSH Command With Details
    [Documentation]    Executes a command and returns stdout, stderr and return code.
    [Arguments]    ${command}    ${alias}=${DEFAULT_ALIAS}

    Switch Connection    ${alias}

    ${stdout}    ${stderr}    ${rc}=    Execute Command
    ...    ${command}
    ...    return_stdout=True
    ...    return_stderr=True
    ...    return_rc=True

    RETURN    ${stdout}    ${stderr}    ${rc}


Execute SSH Command And Verify Success
    [Documentation]    Executes a command and verifies return code is zero.
    [Arguments]    ${command}    ${alias}=${DEFAULT_ALIAS}

    ${stdout}    ${stderr}    ${rc}=    Execute SSH Command With Details
    ...    ${command}
    ...    ${alias}

    Should Be Equal As Integers
    ...    ${rc}
    ...    0
    ...    msg=Command failed with return code ${rc}\n${stderr}

    RETURN    ${stdout}


Execute SSH Command And Verify Output
    [Documentation]    Executes a command and verifies output contains expected text.
    [Arguments]    ${command}    ${expected_output}
    ...    ${alias}=${DEFAULT_ALIAS}

    ${stdout}=    Execute SSH Command
    ...    ${command}
    ...    ${alias}

    Should Contain    ${stdout}    ${expected_output}

    RETURN    ${stdout}


Execute SSH Command And Verify Error
    [Documentation]    Executes a command and verifies stderr contains expected text.
    [Arguments]    ${command}    ${expected_error}
    ...    ${alias}=${DEFAULT_ALIAS}

    ${stdout}    ${stderr}    ${rc}=    Execute SSH Command With Details
    ...    ${command}
    ...    ${alias}

    Should Contain    ${stderr}    ${expected_error}

    RETURN    ${stderr}


Get Current SSH User
    [Documentation]    Returns the current logged-in SSH user.
    [Arguments]    ${alias}=${DEFAULT_ALIAS}

    ${user}=    Execute SSH Command    whoami    ${alias}

    RETURN    ${user}


Get Current SSH Directory
    [Documentation]    Returns the current working directory.
    [Arguments]    ${alias}=${DEFAULT_ALIAS}

    ${directory}=    Execute SSH Command    pwd    ${alias}

    RETURN    ${directory}


# =============================================================================
# FILE TRANSFER
# =============================================================================

Upload File To SSH
    [Documentation]    Uploads a local file to the remote server.
    [Arguments]    ${local_file}    ${remote_file}
    ...    ${alias}=${DEFAULT_ALIAS}

    Switch Connection    ${alias}

    Put File    ${local_file}    ${remote_file}


Download File From SSH
    [Documentation]    Downloads a file from the remote server.
    [Arguments]    ${remote_file}    ${local_file}
    ...    ${alias}=${DEFAULT_ALIAS}

    Switch Connection    ${alias}

    SSHLibrary.Get File    ${remote_file}    ${local_file}


Upload Directory To SSH
    [Documentation]    Uploads a local directory to the remote server.
    [Arguments]    ${local_directory}    ${remote_directory}
    ...    ${alias}=${DEFAULT_ALIAS}

    Switch Connection    ${alias}

    Put Directory    ${local_directory}    ${remote_directory}


Download Directory From SSH
    [Documentation]    Downloads a remote directory.
    [Arguments]    ${remote_directory}    ${local_directory}
    ...    ${alias}=${DEFAULT_ALIAS}

    Switch Connection    ${alias}

    Get Directory    ${remote_directory}    ${local_directory}


# =============================================================================
# VALIDATION UTILITIES
# =============================================================================

File Exists On SSH
    [Documentation]    Verifies that a file exists on the remote server.
    [Arguments]    ${remote_file}    ${alias}=${DEFAULT_ALIAS}

    ${status}=    Execute SSH Command    test -f ${remote_file} && echo EXISTS || echo NOT_FOUND    ${alias}
    ${exists}=    Evaluate    'EXISTS' in '${status}'

    RETURN    ${exists}


Directory Exists On SSH
    [Documentation]    Verifies that a directory exists on the remote server.
    [Arguments]    ${remote_directory}    ${alias}=${DEFAULT_ALIAS}

    ${status}=    Execute SSH Command    test -d ${remote_directory} && echo EXISTS || echo NOT_FOUND    ${alias}
    ${exists}=    Evaluate    'EXISTS' in '${status}'

    RETURN    ${exists}