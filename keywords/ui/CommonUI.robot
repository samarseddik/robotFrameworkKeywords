*** Settings ***
Documentation    Reusable keywords for browser and context management.
...              Foundation for all UI keyword files.
...              Generic and project-agnostic — works with any web application.
Library          Browser
Library          BuiltIn
Library          OperatingSystem

*** Variables ***
${DEFAULT_BROWSER}      chromium
${DEFAULT_TIMEOUT}      30s
${DEFAULT_HEADLESS}     ${HEADLESS}

*** Keywords ***
# =============================================================================
# BROWSER MANAGEMENT
# =============================================================================

Open Browser Session
    [Documentation]    Opens a new browser session with specified options.
    [Arguments]    ${browser}=${DEFAULT_BROWSER}
    ...            ${headless}=${DEFAULT_HEADLESS}
    ...            ${timeout}=${DEFAULT_TIMEOUT}

    New Browser    ${browser}    headless=${headless}

    Set Browser Timeout    ${timeout}

    Log    Browser session opened: ${browser} | headless=${headless}    level=INFO

    RETURN    ${browser}


Close Browser Session
    [Documentation]    Closes the current browser session.

    Close Browser

    Log    Browser session closed    level=INFO


Close All Browser Sessions
    [Documentation]    Closes all open browser sessions.

    Close Browser    ALL

    Log    All browser sessions closed    level=INFO


Get Browser Version
    [Documentation]    Returns the current browser version.

    ${version}=    Evaluate JavaScript    ${None}
    ...    navigator.userAgent || 'unknown'

    Log    Browser version: ${version}    level=INFO

    RETURN    ${version}


# =============================================================================
# CONTEXT MANAGEMENT
# =============================================================================

Create Browser Context
    [Documentation]    Creates a new browser context with optional settings.
    [Arguments]    ${viewport_width}=1920
    ...            ${viewport_height}=1080
    ...            ${locale}=en-US
    ...            ${timezone}=UTC

    New Context
    ...    viewport={'width': ${viewport_width}, 'height': ${viewport_height}}
    ...    locale=${locale}
    ...    timezoneId=${timezone}

    Log    Browser context created: ${viewport_width}x${viewport_height}    level=INFO


Close Browser Context
    [Documentation]    Closes the current browser context.

    Close Context

    Log    Browser context closed    level=INFO


Set Browser Context Options
    [Documentation]    Sets options on the current browser context.
    [Arguments]    ${option}    ${value}

    Set Context Option    ${option}    ${value}

    Log    Context option set: ${option}=${value}    level=INFO


# =============================================================================
# PAGE MANAGEMENT
# =============================================================================

Open New Page
    [Documentation]    Opens a new page in the current browser context.
    [Arguments]    ${url}=${EMPTY}

    New Page    ${url}

    Run Keyword If    '${url}' != '${EMPTY}'
    ...     Wait For Load State    networkidle


    Log    New page opened: ${url}    level=INFO


Close Current Page
    [Documentation]    Closes the current page.

    Close Page

    Log    Current page closed    level=INFO


Get Current Page URL
    [Documentation]    Returns the URL of the current page.

    ${url}=    Get Url

    Log    Current URL: ${url}    level=INFO

    RETURN    ${url}


Get Current Page Title
    [Documentation]    Returns the title of the current page.

    ${title}=    Get Title

    Log    Current page title: ${title}    level=INFO

    RETURN    ${title}


# =============================================================================
# CONFIGURATION
# =============================================================================

Set Browser Timeout
    [Documentation]    Sets the global browser timeout.
    [Arguments]    ${timeout}=${DEFAULT_TIMEOUT}

    Browser.Set Browser Timeout    ${timeout}

    Log    Browser timeout set to: ${timeout}    level=INFO


Set Browser Speed
    [Documentation]    Sets the browser speed by adding delay between actions.
    [Arguments]    ${delay}=0ms

    Set Browser Timeout    ${delay}

    Log    Browser speed set to: ${delay}    level=INFO


Configure Browser Options
    [Documentation]    Configures browser with common options for test automation.
    [Arguments]    ${browser}=${DEFAULT_BROWSER}
    ...            ${headless}=${DEFAULT_HEADLESS}
    ...            ${viewport_width}=1920
    ...            ${viewport_height}=1080
    ...            ${timeout}=${DEFAULT_TIMEOUT}

    Open Browser Session    ${browser}    ${headless}    ${timeout}
    Create Browser Context    ${viewport_width}    ${viewport_height}
    Open New Page    about:blank

    Log    Browser fully configured    level=INFO


Take Page Screenshot
    [Documentation]    Takes a screenshot of the current page.
    [Arguments]    ${screenshot_path}=${SCREENSHOT_PATH}
    ...            ${file_name}=screenshot.png

    ${full_path}=    Set Variable    ${screenshot_path}/${file_name}

    Run Keyword If    '${screenshot_path}' != '${EMPTY}'
    ...    Create Directory    ${screenshot_path}

    Take Screenshot    filename=${full_path}

    Log    Screenshot saved: ${full_path}    level=INFO

    RETURN    ${full_path}


# =============================================================================
# STATE MANAGEMENT
# =============================================================================

Clear Browser Cookies
    [Documentation]    Clears all cookies from the current browser context.

    Browser.Delete All Cookies

    Log    Browser cookies cleared    level=INFO


Clear Browser Cache
    [Documentation]    Clears the browser cache by creating a fresh context.
    [Arguments]    ${viewport_width}=1920
    ...            ${viewport_height}=1080

    Close Browser Context
    Create Browser Context    ${viewport_width}    ${viewport_height}

    Log    Browser cache cleared    level=INFO


Get Browser Cookies
    [Documentation]    Returns all cookies from the current browser context.

    ${cookies}=    Get Cookies

    Log    Retrieved ${cookies.__len__()} cookies    level=INFO

    RETURN    ${cookies}


Set Browser Cookie
    [Documentation]    Sets a cookie in the current browser context.
    [Arguments]    ${name}    ${value}    ${url}=${EMPTY}

    Add Cookie    ${name}    ${value}    url=${url}

    Log    Cookie set: ${name}=${value}    level=INFO