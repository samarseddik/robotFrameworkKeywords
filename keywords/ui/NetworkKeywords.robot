*** Settings ***
Documentation    Reusable keywords for network interception, mocking and monitoring.
...              Handles request/response interception, API mocking and network conditions.
...              Generic and project-agnostic — works with any web application.
Library          Browser
Library          BuiltIn
Library          Collections
Resource         ValidationKeywords.robot

*** Variables ***
${DEFAULT_TIMEOUT}    30s

*** Keywords ***
# =============================================================================
# REQUEST INTERCEPTION
# =============================================================================

Intercept Request
    [Documentation]    Sets up interception for requests matching a URL pattern.
    [Arguments]    ${url_pattern}

    ${promise}=    Promise To    Wait For Request    ${url_pattern}

    Log    Intercepting requests matching: ${url_pattern}    level=INFO

    RETURN    ${promise}


Wait For Request
    [Documentation]    Waits for a request matching a URL pattern to be made.
    [Arguments]    ${url_pattern}    ${timeout}=${DEFAULT_TIMEOUT}

    ${request}=    Browser.Wait For Request    ${url_pattern}    timeout=${timeout}

    Log    Request received: ${url_pattern}    level=INFO

    RETURN    ${request}


Wait For Response
    [Documentation]    Waits for a response matching a URL pattern to be received.
    [Arguments]    ${url_pattern}    ${timeout}=${DEFAULT_TIMEOUT}

    ${response}=    Browser.Wait For Response    ${url_pattern}    timeout=${timeout}

    Log    Response received: ${url_pattern}    level=INFO

    RETURN    ${response}


Get Request Details
    [Documentation]    Returns details of a captured request object.
    [Arguments]    ${request}

    Log    Request details: ${request}    level=INFO

    RETURN    ${request}


# =============================================================================
# MOCKING
# =============================================================================

# Mock API Response
#     [Documentation]    Mocks an API endpoint to return a specific response.
#     [Arguments]    ${url_pattern}    ${response_body}    ${status_code}=200
#     Route 


#     New Route    ${url_pattern}    handler=mock_response
    
#     Log    Mocked API: ${url_pattern} with status ${status_code}    level=INFO
Mock API Response
    [Documentation]    Mocks an API endpoint to return a specific response.
    [Arguments]    ${url}    ${body}    ${status}=200    ${method}=GET

    ${response}=    Create Dictionary
    ...    status=${status}
    ...    body=${body}
    ...    contentType=application/json

    Route    ${url}    ${response}    method=${method}
    
Mock API Error
    [Documentation]    Mocks an API endpoint to return an error response.
    [Arguments]    ${url_pattern}    ${status_code}=500    ${error_message}=Internal Server Error

    New Route    ${url_pattern}    handler=mock_error

    Log    Mocked API error: ${url_pattern} with status ${status_code}    level=INFO


Remove Mock
    [Documentation]    Removes a previously set mock for a URL pattern.
    [Arguments]    ${url_pattern}

    Unroute    ${url_pattern}

    Log    Mock removed for: ${url_pattern}    level=INFO


# =============================================================================
# NETWORK MONITORING
# =============================================================================

Start Network Monitoring
    [Documentation]    Starts capturing all network requests on the current page.

    ${promise}=    Promise To    Wait For All Requests

    Log    Network monitoring started    level=INFO

    RETURN    ${promise}


Stop Network Monitoring
    [Documentation]    Stops network monitoring and returns captured data.
    [Arguments]    ${promise}

    ${requests}=    Wait For    ${promise}

    Log    Network monitoring stopped    level=INFO

    RETURN    ${requests}


Get All Requests
    [Documentation]    Returns all network requests matching a URL pattern made during the session.
    [Arguments]    ${url_pattern}=**

    ${requests}=    Get Url    ${url_pattern}

    Log    Retrieved requests matching: ${url_pattern}    level=INFO

    RETURN    ${requests}


Get All Responses
    [Documentation]    Returns all network responses matching a URL pattern made during the session.
    [Arguments]    ${url_pattern}=**

    ${responses}=    Get Url    ${url_pattern}

    Log    Retrieved responses matching: ${url_pattern}    level=INFO

    RETURN    ${responses}


# =============================================================================
# RESPONSE VALIDATION
# =============================================================================

Verify Response Status
    [Documentation]    Verifies that a response has the expected HTTP status code.
    [Arguments]    ${url_pattern}    ${expected_status}    ${timeout}=${DEFAULT_TIMEOUT}

    ${response}=    Wait For Response    ${url_pattern}    timeout=${timeout}
    ${status}=    Set Variable    ${response}[status]

    Should Be Equal As Integers    ${status}    ${expected_status}
    ...    Status mismatch. Expected: ${expected_status} | Got: ${status}

    Log    Response status verified: ${expected_status}    level=INFO


Verify Response Contains
    [Documentation]    Verifies that a response body contains expected text.
    [Arguments]    ${url_pattern}    ${expected_text}    ${timeout}=${DEFAULT_TIMEOUT}

    ${response}=    Wait For Response    ${url_pattern}    timeout=${timeout}
    ${body}=    Set Variable    ${response}[body]

    Should Contain    ${body}    ${expected_text}
    ...    Response body does not contain: ${expected_text}

    Log    Response body verified to contain: ${expected_text}    level=INFO


Verify Request Was Made
    [Documentation]    Verifies that a request matching a URL pattern was made.
    [Arguments]    ${url_pattern}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Request    ${url_pattern}    timeout=${timeout}

    Log    Request verified to have been made: ${url_pattern}    level=INFO


# =============================================================================
# NETWORK CONDITIONS
# =============================================================================

Set Network Offline
    [Documentation]    Simulates the browser going offline.

    Set Offline    True

    Log    Network set to offline    level=INFO


Set Network Online
    [Documentation]    Restores the browser network connection.

    Set Offline    False

    Log    Network set to online    level=INFO


Throttle Network
    [Documentation]    Throttles network speed to simulate slow connections.
    [Arguments]    ${download}=50000    ${upload}=20000    ${latency}=500

    New Context    networkContext={'offline': False}

    Log    Network throttled — download: ${download} upload: ${upload} latency: ${latency}    level=INFO