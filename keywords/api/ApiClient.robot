*** Settings ***
Documentation    Reusable keywords for HTTP session management and REST API requests.
...              Part of the Keyword-Driven Testing strategy.
Library          RequestsLibrary
Library          Collections
Library          String
Library          BuiltIn

*** Variables ***
${API_SESSION}          ${None}
${API_BASE_URL}         http://localhost:8080
${API_TIMEOUT}          30
${API_VERIFY_SSL}       ${True}
${API_SESSION_ALIAS}    api_session
${API_LAST_RESPONSE}    ${None}


*** Keywords ***
Create API Session
    [Documentation]    Creates a reusable HTTP session for the given base URL.
    ...                This session is used by all request keywords in ApiClient.
    [Arguments]    ${base_url}=${API_BASE_URL}    ${alias}=${API_SESSION_ALIAS}
    ...            ${verify_ssl}=${API_VERIFY_SSL}    ${timeout}=${API_TIMEOUT}

    Log    Creating API session for ${base_url} with alias '${alias}'    level=INFO

    Create Session    ${alias}    ${base_url}
    ...               verify=${verify_ssl}
    ...               timeout=${timeout}

    Set Suite Variable    ${API_SESSION}       ${alias}
    Set Suite Variable    ${API_BASE_URL}      ${base_url}
    Set Suite Variable    ${API_TIMEOUT}       ${timeout}
    Set Suite Variable    ${API_VERIFY_SSL}    ${verify_ssl}

    Log    API session '${alias}' created successfully    level=INFO

    RETURN    ${alias}


Delete API Session
    [Documentation]    Deletes the active HTTP session and cleans up state.
    ...                Should be called in test teardown to ensure proper cleanup.
    [Arguments]    ${alias}=${API_SESSION_ALIAS}

    Run Keyword And Ignore Error    Delete All Sessions

    Set Suite Variable    ${API_SESSION}        ${None}
    Set Suite Variable    ${API_LAST_RESPONSE}  ${None}

    Log    API session '${alias}' deleted    level=INFO

    RETURN    ${True}


GET Request
    [Documentation]    Sends an HTTP GET request to the given endpoint.
    [Arguments]    ${endpoint}    ${headers}=${None}    ${params}=${None}
    ...            ${alias}=${API_SESSION_ALIAS}    ${timeout}=${API_TIMEOUT}

    Log    GET ${API_BASE_URL}${endpoint}    level=INFO

    ${response}=    GET On Session    ${alias}    ${endpoint}
    ...             headers=${headers}
    ...             params=${params}
    ...             timeout=${timeout}
    ...             expected_status=ANY

    Set Suite Variable    ${API_LAST_RESPONSE}    ${response}

    Log    GET ${endpoint} → ${response.status_code}    level=INFO

    RETURN    ${response}


POST Request
    [Documentation]    Sends an HTTP POST request with a JSON body to the given endpoint.
    [Arguments]    ${endpoint}    ${body}=${None}    ${headers}=${None}
    ...            ${alias}=${API_SESSION_ALIAS}    ${timeout}=${API_TIMEOUT}

    Log    POST ${API_BASE_URL}${endpoint}    level=INFO

    ${response}=    POST On Session    ${alias}    ${endpoint}
    ...             json=${body}
    ...             headers=${headers}
    ...             timeout=${timeout}
    ...             expected_status=ANY

    Set Suite Variable    ${API_LAST_RESPONSE}    ${response}

    Log    POST ${endpoint} → ${response.status_code}    level=INFO

    RETURN    ${response}


PUT Request
    [Documentation]    Sends an HTTP PUT request with a JSON body to the given endpoint.
    [Arguments]    ${endpoint}    ${body}=${None}    ${headers}=${None}
    ...            ${alias}=${API_SESSION_ALIAS}    ${timeout}=${API_TIMEOUT}

    Log    PUT ${API_BASE_URL}${endpoint}    level=INFO

    ${response}=    PUT On Session    ${alias}    ${endpoint}
    ...             json=${body}
    ...             headers=${headers}
    ...             timeout=${timeout}
    ...             expected_status=ANY

    Set Suite Variable    ${API_LAST_RESPONSE}    ${response}

    Log    PUT ${endpoint} → ${response.status_code}    level=INFO

    RETURN    ${response}


DELETE Request
    [Documentation]    Sends an HTTP DELETE request to the given endpoint.
    [Arguments]    ${endpoint}    ${headers}=${None}
    ...            ${alias}=${API_SESSION_ALIAS}    ${timeout}=${API_TIMEOUT}

    Log    DELETE ${API_BASE_URL}${endpoint}    level=INFO

    ${response}=    DELETE On Session    ${alias}    ${endpoint}
    ...             headers=${headers}
    ...             timeout=${timeout}
    ...             expected_status=ANY

    Set Suite Variable    ${API_LAST_RESPONSE}    ${response}

    Log    DELETE ${endpoint} → ${response.status_code}    level=INFO

    RETURN    ${response}


PATCH Request
    [Documentation]    Sends an HTTP PATCH request with a JSON body to the given endpoint.
    [Arguments]    ${endpoint}    ${body}=${None}    ${headers}=${None}
    ...            ${alias}=${API_SESSION_ALIAS}    ${timeout}=${API_TIMEOUT}

    Log    PATCH ${API_BASE_URL}${endpoint}    level=INFO

    ${response}=    PATCH On Session    ${alias}    ${endpoint}
    ...             json=${body}
    ...             headers=${headers}
    ...             timeout=${timeout}
    ...             expected_status=ANY

    Set Suite Variable    ${API_LAST_RESPONSE}    ${response}

    Log    PATCH ${endpoint} → ${response.status_code}    level=INFO

    RETURN    ${response}


Get Last Response
    [Documentation]    Returns the last HTTP response stored in suite scope.
    ...                Useful when the response was not captured at call site.

    Should Not Be Equal    ${API_LAST_RESPONSE}    ${None}
    ...    No API response found. Make sure a request keyword was called first.

    RETURN    ${API_LAST_RESPONSE}


Get Response Body
    [Documentation]    Returns the parsed JSON body of a response.
    ...                If no response is passed, uses the last stored response.
    [Arguments]    ${response}=${None}

    ${target}=    Set Variable If    '${response}' == '${None}'    ${API_LAST_RESPONSE}    ${response}

    Should Not Be Equal    ${target}    ${None}
    ...    No response available. Pass a response or call a request keyword first.

    ${body}=    Set Variable    ${target.json()}

    RETURN    ${body}


Get Response Status Code
    [Documentation]    Returns the HTTP status code of a response as an integer.
    ...                If no response is passed, uses the last stored response.
    [Arguments]    ${response}=${None}

    ${target}=    Set Variable If    '${response}' == '${None}'    ${API_LAST_RESPONSE}    ${response}

    Should Not Be Equal    ${target}    ${None}
    ...    No response available. Pass a response or call a request keyword first.

    RETURN    ${target.status_code}


Verify API Session Is Active
    [Documentation]    Verifies that an active API session exists.

    Should Not Be Equal    ${API_SESSION}    ${None}
    ...    No active API session. Call 'Create API Session' first.

    Log    API session '${API_SESSION}' is active    level=INFO

    RETURN    ${True}
