*** Settings ***
Documentation    Reusable keywords for multi-context and multi-session browser testing.
...              Handles multiple browser contexts, simulated users, tabs and isolation testing.
...              Generic and project-agnostic — works with any web application.
Library          Browser
Library          BuiltIn
Library          Collections
Library          OperatingSystem
Resource         ValidationKeywords.robot

*** Variables ***
${DEFAULT_VIEWPORT_WIDTH}     1920
${DEFAULT_VIEWPORT_HEIGHT}    1080

*** Keywords ***
# =============================================================================
# CONTEXT MANAGEMENT
# =============================================================================

Create New Browser Context
    [Documentation]    Creates a new isolated browser context with an optional alias.
    [Arguments]    ${alias}=${EMPTY}
    ...            ${viewport_width}=${DEFAULT_VIEWPORT_WIDTH}
    ...            ${viewport_height}=${DEFAULT_VIEWPORT_HEIGHT}

    ${context_id}=    New Context
    ...    viewport={'width': ${viewport_width}, 'height': ${viewport_height}}

    Run Keyword If    '${alias}' != '${EMPTY}'
    ...    Set Suite Variable    ${CONTEXT_${alias}}    ${context_id}

    Log    New browser context created: ${context_id}    level=INFO

    RETURN    ${context_id}


Switch To Context
    [Documentation]    Switches to a specific browser context by id.
    [Arguments]    ${context_id}

    Switch Context    ${context_id}

    Log    Switched to context: ${context_id}    level=INFO


Close Specific Context
    [Documentation]    Closes a specific browser context by id.
    [Arguments]    ${context_id}

    Switch Context    ${context_id}
    Close Context

    Log    Closed context: ${context_id}    level=INFO


Get All Contexts
    [Documentation]    Returns all open browser context ids.

    ${contexts}=    Get Browser Catalog

    Log    Retrieved browser catalog    level=INFO

    RETURN    ${contexts}


# =============================================================================
# MULTI-USER SIMULATION
# =============================================================================

Create User Session
    [Documentation]    Creates a new isolated context and page to simulate a separate user.
    [Arguments]    ${user_alias}
    ...            ${url}=${EMPTY}
    ...            ${viewport_width}=${DEFAULT_VIEWPORT_WIDTH}
    ...            ${viewport_height}=${DEFAULT_VIEWPORT_HEIGHT}

    ${context_id}=    New Context
    ...    viewport={'width': ${viewport_width}, 'height': ${viewport_height}}

    ${page_id}=    New Page    ${url}

    Set Suite Variable    ${USER_${user_alias}_CONTEXT}    ${context_id}
    Set Suite Variable    ${USER_${user_alias}_PAGE}    ${page_id}

    Log    User session created: ${user_alias}    level=INFO

    RETURN    ${context_id}


Switch To User Session
    [Documentation]    Switches to a previously created user session.
    [Arguments]    ${user_alias}

    ${page_id}=    Set Variable    ${USER_${user_alias}_PAGE}

    Switch Page    ${page_id}

    Log    Switched to user session: ${user_alias}    level=INFO


Close User Session
    [Documentation]    Closes a specific user session and its context.
    [Arguments]    ${user_alias}

    ${context_id}=    Set Variable    ${USER_${user_alias}_CONTEXT}

    Switch Context    ${context_id}
    Close Context

    Log    User session closed: ${user_alias}    level=INFO


Close All User Sessions
    [Documentation]    Closes all browser contexts representing user sessions.

    Close Context    ALL

    Log    All user sessions closed    level=INFO


# =============================================================================
# MULTI-TAB / WINDOW
# =============================================================================

Open Link In New Tab
    [Documentation]    Opens a URL in a new tab within the current context.
    [Arguments]    ${url}

    ${page_id}=    New Page    ${url}

    Log    Opened link in new tab: ${url}    level=INFO

    RETURN    ${page_id}


Get Tab Count
    [Documentation]    Returns the number of open tabs in the current context.

    ${tabs}=    Get Page Ids    ALL
    ${count}=    Get Length    ${tabs}

    Log    Tab count: ${count}    level=INFO

    RETURN    ${count}


Verify Tab Count
    [Documentation]    Verifies that the number of open tabs matches expected count.
    [Arguments]    ${expected_count}

    ${actual_count}=    Get Tab Count

    Should Be Equal As Integers    ${actual_count}    ${expected_count}
    ...    Tab count mismatch. Expected: ${expected_count} | Got: ${actual_count}

    Log    Tab count verified: ${expected_count}    level=INFO


# =============================================================================
# CROSS-CONTEXT ACTIONS
# =============================================================================

Copy Cookies Between Contexts
    [Documentation]    Copies cookies from current context to a target context.
    [Arguments]    ${target_context_id}

    ${cookies}=    Get Cookies

    Switch Context    ${target_context_id}

    FOR    ${cookie}    IN    @{cookies}
        Add Cookie
        ...    ${cookie}[name]
        ...    ${cookie}[value]
        ...    url=${cookie}[domain]
    END

    Log    Cookies copied to context: ${target_context_id}    level=INFO


Share Storage State
    [Documentation]    Saves the storage state of the current context for reuse.

    ${state_file}=    Save Storage State

    Log    Storage state saved to: ${state_file}    level=INFO

    RETURN    ${state_file}


# =============================================================================
# ISOLATION TESTING
# =============================================================================

Verify Contexts Are Isolated
    [Documentation]    Verifies that two contexts do not share cookies (isolation check).
    [Arguments]    ${context_id_1}    ${context_id_2}

    Switch Context    ${context_id_1}
    ${cookies_1}=    Get Cookies

    Switch Context    ${context_id_2}
    ${cookies_2}=    Get Cookies

    Should Not Be Equal    ${cookies_1}    ${cookies_2}
    ...    Contexts are not isolated — cookies match between contexts

    Log    Contexts verified as isolated    level=INFO


Get Context Storage State
    [Documentation]    Saves and returns the path to the current context's storage state file.

    ${state_file}=    Save Storage State

    Log    Storage state saved to: ${state_file}    level=INFO

    RETURN    ${state_file}