*** Settings ***
Documentation    Reusable keywords for API authentication (Bearer token, Basic auth, API key).
...              Part of the Keyword-Driven Testing strategy.
Library          RequestsLibrary
Library          Collections
Library          String
Library          BuiltIn
Resource         ApiClient.robot

*** Variables ***
${AUTH_TYPE}            ${None}
${AUTH_TOKEN}           ${None}
${AUTH_API_KEY}         ${None}
${AUTH_API_KEY_NAME}    X-API-Key
&{AUTH_HEADERS}         ${EMPTY}


*** Keywords ***
Set Bearer Token
    [Documentation]    Configures Bearer token authentication.
    ...                Stores the Authorization header for use in subsequent requests.
    [Arguments]    ${token}

    Should Not Be Empty    ${token}    Bearer token cannot be empty

    ${auth_headers}=    Create Dictionary
    ...                 Authorization=Bearer ${token}

    Set Suite Variable    ${AUTH_TYPE}      Bearer
    Set Suite Variable    ${AUTH_TOKEN}     ${token}
    Set Suite Variable    &{AUTH_HEADERS}   &{auth_headers}

    Log    Bearer token authentication configured    level=INFO

    RETURN    ${auth_headers}


Set Basic Auth
    [Documentation]    Configures Basic authentication using username and password.
    ...                Encodes credentials and stores the Authorization header.
    [Arguments]    ${username}    ${password}

    Should Not Be Empty    ${username}    Username cannot be empty
    Should Not Be Empty    ${password}    Password cannot be empty

    ${credentials}=      Set Variable    ${username}:${password}
    ${encoded}=          Evaluate
    ...                  __import__('base64').b64encode('${credentials}'.encode()).decode()
    ${auth_headers}=     Create Dictionary
    ...                  Authorization=Basic ${encoded}

    Set Suite Variable    ${AUTH_TYPE}      Basic
    Set Suite Variable    &{AUTH_HEADERS}   &{auth_headers}

    Log    Basic authentication configured for user: ${username}    level=INFO

    RETURN    ${auth_headers}


Set API Key Auth
    [Documentation]    Configures API key authentication.
    ...                The key can be sent as a custom header (default: X-API-Key).
    [Arguments]    ${api_key}    ${header_name}=${AUTH_API_KEY_NAME}

    Should Not Be Empty    ${api_key}    API key cannot be empty

    ${auth_headers}=    Create Dictionary
    ...                 ${header_name}=${api_key}

    Set Suite Variable    ${AUTH_TYPE}         API_KEY
    Set Suite Variable    ${AUTH_API_KEY}      ${api_key}
    Set Suite Variable    ${AUTH_API_KEY_NAME}    ${header_name}
    Set Suite Variable    &{AUTH_HEADERS}      &{auth_headers}

    Log    API key authentication configured with header: ${header_name}    level=INFO

    RETURN    ${auth_headers}


Get Auth Headers
    [Documentation]    Returns the currently configured authentication headers.
    ...                Use this to merge auth headers into request headers.

    Should Not Be Equal    ${AUTH_TYPE}    ${None}
    ...    No authentication configured. Call Set Bearer Token, Set Basic Auth, or Set API Key Auth first.

    RETURN    ${AUTH_HEADERS}


Get Auth Type
    [Documentation]    Returns the currently configured authentication type.
    ...                Possible values: Bearer, Basic, API_KEY, or ${None}.

    RETURN    ${AUTH_TYPE}


Clear Auth
    [Documentation]    Clears all authentication configuration.
    ...                Should be called in teardown when auth should not persist.

    Set Suite Variable    ${AUTH_TYPE}         ${None}
    Set Suite Variable    ${AUTH_TOKEN}        ${None}
    Set Suite Variable    ${AUTH_API_KEY}      ${None}
    Set Suite Variable    ${AUTH_API_KEY_NAME}    X-API-Key

    ${empty}=    Create Dictionary
    Set Suite Variable    &{AUTH_HEADERS}    &{empty}

    Log    Authentication configuration cleared    level=INFO

    RETURN    ${True}


Merge Auth With Headers
    [Documentation]    Merges authentication headers with any additional headers provided.
    ...                Returns the combined headers dictionary ready to pass to a request keyword.
    [Arguments]    ${extra_headers}=${None}

    Should Not Be Equal    ${AUTH_TYPE}    ${None}
    ...    No authentication configured. Call an auth setup keyword first.

    ${merged}=    Copy Dictionary    ${AUTH_HEADERS}

    Run Keyword If    ${extra_headers} != ${None}
    ...    Collections.Update Dictionary    ${merged}    &{extra_headers}

    RETURN    ${merged}