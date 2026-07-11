*** Settings ***
Documentation    Reusable keywords for API response validation (status codes, body, headers).
...              Part of the Keyword-Driven Testing strategy.
Library          RequestsLibrary
Library          Collections
Library          String
Library          BuiltIn
Resource         ApiClient.robot

*** Variables ***
${VALIDATION_DEFAULT_ENCODING}    utf-8


*** Keywords ***
Validate Status Code
    [Documentation]    Validates that the response status code matches the expected value.
    [Arguments]    ${expected_status}    ${response}=${None}

    ${target}=    Set Variable If    '${response}' == '${None}'    ${API_LAST_RESPONSE}    ${response}

    Should Not Be Equal    ${target}    ${None}
    ...    No response available. Pass a response or call a request keyword first.

    Should Be Equal As Integers    ${target.status_code}    ${expected_status}
    ...    Expected status code ${expected_status} but got ${target.status_code}

    Log    Status code validated: ${target.status_code}    level=INFO

    RETURN    ${True}


Validate Status Code In List
    [Documentation]    Validates that the response status code is one of the expected values.
    [Arguments]    ${expected_statuses}    ${response}=${None}

    ${target}=    Set Variable If    '${response}' == '${None}'    ${API_LAST_RESPONSE}    ${response}

    Should Not Be Equal    ${target}    ${None}
    ...    No response available. Pass a response or call a request keyword first.

    Should Contain    ${expected_statuses}    ${target.status_code}
    ...    Status code ${target.status_code} not in expected list: ${expected_statuses}

    Log    Status code ${target.status_code} is in expected list    level=INFO

    RETURN    ${True}


Validate Response Body Contains Key
    [Documentation]    Validates that the JSON response body contains the given key.
    [Arguments]    ${key}    ${response}=${None}

    ${target}=    Set Variable If    '${response}' == '${None}'    ${API_LAST_RESPONSE}    ${response}

    Should Not Be Equal    ${target}    ${None}
    ...    No response available. Pass a response or call a request keyword first.

    ${body}=    Set Variable    ${target.json()}

    Dictionary Should Contain Key    ${body}    ${key}
    ...    Response body does not contain key: ${key}

    Log    Key '${key}' found in response body    level=INFO

    RETURN    ${True}


Validate Response Body Field Value
    [Documentation]    Validates that a field in the JSON response body matches the expected value.
    [Arguments]    ${key}    ${expected_value}    ${response}=${None}

    ${target}=    Set Variable If    '${response}' == '${None}'    ${API_LAST_RESPONSE}    ${response}

    Should Not Be Equal    ${target}    ${None}
    ...    No response available. Pass a response or call a request keyword first.

    ${body}=    Set Variable    ${target.json()}

    Dictionary Should Contain Key    ${body}    ${key}
    ...    Response body does not contain key: ${key}

    Should Be Equal As Strings    ${body}[${key}]    ${expected_value}
    ...    Expected '${key}' = '${expected_value}' but got '${body}[${key}]'

    Log    Field '${key}' validated: ${body}[${key}]    level=INFO

    RETURN    ${True}


Validate Response Body Is Not Empty
    [Documentation]    Validates that the response body is not empty.
    [Arguments]    ${response}=${None}

    ${target}=    Set Variable If    '${response}' == '${None}'    ${API_LAST_RESPONSE}    ${response}

    Should Not Be Equal    ${target}    ${None}
    ...    No response available. Pass a response or call a request keyword first.

    Should Not Be Empty    ${target.text}
    ...    Response body is empty

    Log    Response body is not empty    level=INFO

    RETURN    ${True}


Validate Response Header Contains
    [Documentation]    Validates that a specific header exists in the response.
    [Arguments]    ${header_name}    ${response}=${None}

    ${target}=    Set Variable If    '${response}' == '${None}'    ${API_LAST_RESPONSE}    ${response}

    Should Not Be Equal    ${target}    ${None}
    ...    No response available. Pass a response or call a request keyword first.

    Dictionary Should Contain Key    ${target.headers}    ${header_name}
    ...    Response does not contain header: ${header_name}

    Log    Header '${header_name}' found in response    level=INFO

    RETURN    ${True}


Validate Response Header Value
    [Documentation]    Validates that a response header matches the expected value.
    [Arguments]    ${header_name}    ${expected_value}    ${response}=${None}

    ${target}=    Set Variable If    '${response}' == '${None}'    ${API_LAST_RESPONSE}    ${response}

    Should Not Be Equal    ${target}    ${None}
    ...    No response available. Pass a response or call a request keyword first.

    Dictionary Should Contain Key    ${target.headers}    ${header_name}
    ...    Response does not contain header: ${header_name}

    Should Be Equal As Strings    ${target.headers}[${header_name}]    ${expected_value}
    ...    Expected header '${header_name}' = '${expected_value}' but got '${target.headers}[${header_name}]'

    Log    Header '${header_name}' validated: ${target.headers}[${header_name}]    level=INFO

    RETURN    ${True}


Validate Response Time
    [Documentation]    Validates that the response time is within the acceptable limit in seconds.
    [Arguments]    ${max_seconds}=5    ${response}=${None}

    ${target}=    Set Variable If    '${response}' == '${None}'    ${API_LAST_RESPONSE}    ${response}

    Should Not Be Equal    ${target}    ${None}
    ...    No response available. Pass a response or call a request keyword first.

    ${elapsed}=    Set Variable    ${target.elapsed.total_seconds()}

    Should Be True    ${elapsed} <= ${max_seconds}
    ...    Response time ${elapsed}s exceeded limit of ${max_seconds}s

    Log    Response time validated: ${elapsed}s (limit: ${max_seconds}s)    level=INFO

    RETURN    ${elapsed}


Validate Response Is JSON
    [Documentation]    Validates that the response body is valid JSON.
    [Arguments]    ${response}=${None}

    ${target}=    Set Variable If    '${response}' == '${None}'    ${API_LAST_RESPONSE}    ${response}

    Should Not Be Equal    ${target}    ${None}
    ...    No response available. Pass a response or call a request keyword first.

    ${status}    ${body}=    Run Keyword And Ignore Error
    ...    Set Variable    ${target.json()}

    Should Be Equal    ${status}    PASS
    ...    Response body is not valid JSON: ${target.text}

    Log    Response body is valid JSON    level=INFO

    RETURN    ${True}


Validate Response List Length
    [Documentation]    Validates that the JSON response body is a list with the expected length.
    [Arguments]    ${expected_length}    ${response}=${None}

    ${target}=    Set Variable If    '${response}' == '${None}'    ${API_LAST_RESPONSE}    ${response}

    Should Not Be Equal    ${target}    ${None}
    ...    No response available. Pass a response or call a request keyword first.

    ${body}=    Set Variable    ${target.json()}

    ${length}=    Get Length    ${body}

    Should Be Equal As Integers    ${length}    ${expected_length}
    ...    Expected list length ${expected_length} but got ${length}

    Log    Response list length validated: ${length}    level=INFO

    RETURN    ${length}