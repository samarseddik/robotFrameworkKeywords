*** Settings ***
Documentation    Reusable keywords for API configuration (headers, timeout, SSL, proxy).
...              Part of the Keyword-Driven Testing strategy.
Library          RequestsLibrary
Library          Collections
Library          String
Library          BuiltIn

*** Variables ***
${DEFAULT_CONTENT_TYPE}     application/json
${DEFAULT_ACCEPT}           application/json
${DEFAULT_TIMEOUT}          30
${DEFAULT_VERIFY_SSL}       ${True}
${DEFAULT_PROXY_HTTP}       ${None}
${DEFAULT_PROXY_HTTPS}      ${None}
&{DEFAULT_HEADERS}          Content-Type=application/json    Accept=application/json


*** Keywords ***
Configure Default Headers
    [Documentation]    Sets the default headers to be used across all API requests.
    [Arguments]    ${content_type}=${DEFAULT_CONTENT_TYPE}    ${accept}=${DEFAULT_ACCEPT}
    ...            ${extra_headers}=${None}

    ${headers}=    Create Dictionary
    ...            Content-Type=${content_type}
    ...            Accept=${accept}

    Run Keyword If    ${extra_headers} != ${None}
    ...    Set To Dictionary    ${headers}    &{extra_headers}

    Set Suite Variable    &{DEFAULT_HEADERS}    &{headers}

    Log    Default headers configured: ${headers}    level=INFO

    RETURN    ${headers}


Get Default Headers
    [Documentation]    Returns the currently configured default headers as a dictionary.

    RETURN    ${DEFAULT_HEADERS}


Configure Timeout
    [Documentation]    Sets the default request timeout in seconds.
    [Arguments]    ${timeout}=${DEFAULT_TIMEOUT}

    Set Suite Variable    ${DEFAULT_TIMEOUT}    ${timeout}

    Log    Default timeout set to ${timeout}s    level=INFO

    RETURN    ${timeout}


Configure SSL Verification
    [Documentation]    Enables or disables SSL certificate verification for API requests.
    [Arguments]    ${verify}=${True}

    Set Suite Variable    ${DEFAULT_VERIFY_SSL}    ${verify}

    Log    SSL verification set to: ${verify}    level=INFO

    RETURN    ${verify}


Configure Proxy
    [Documentation]    Sets HTTP and HTTPS proxy addresses for API requests.
    [Arguments]    ${http_proxy}=${None}    ${https_proxy}=${None}

    Set Suite Variable    ${DEFAULT_PROXY_HTTP}     ${http_proxy}
    Set Suite Variable    ${DEFAULT_PROXY_HTTPS}    ${https_proxy}

    Log    Proxy configured — HTTP: ${http_proxy} | HTTPS: ${https_proxy}    level=INFO

    RETURN    ${True}


Get Proxy Configuration
    [Documentation]    Returns the currently configured proxy settings as a dictionary.

    ${proxy}=    Create Dictionary
    ...          http=${DEFAULT_PROXY_HTTP}
    ...          https=${DEFAULT_PROXY_HTTPS}

    RETURN    ${proxy}


Reset API Configuration
    [Documentation]    Resets all API configuration to default values.
    ...                Useful in suite teardown to avoid state leaking between test suites.

    Set Suite Variable    ${DEFAULT_CONTENT_TYPE}    application/json
    Set Suite Variable    ${DEFAULT_ACCEPT}          application/json
    Set Suite Variable    ${DEFAULT_TIMEOUT}         30
    Set Suite Variable    ${DEFAULT_VERIFY_SSL}      ${True}
    Set Suite Variable    ${DEFAULT_PROXY_HTTP}      ${None}
    Set Suite Variable    ${DEFAULT_PROXY_HTTPS}     ${None}

    ${headers}=    Create Dictionary
    ...            Content-Type=application/json
    ...            Accept=application/json

    Set Suite Variable    &{DEFAULT_HEADERS}    &{headers}

    Log    API configuration reset to defaults    level=INFO

    RETURN    ${True}