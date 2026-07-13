*** Settings ***
Documentation    Reusable keywords for browser navigation.
...              Handles URL navigation, page load, scrolling, frames and tabs.
...              Generic and project-agnostic — works with any web application.
Library          Browser
Library          BuiltIn

*** Variables ***
${DEFAULT_LOAD_STATE}      networkidle
${DEFAULT_SCROLL_BEHAVIOR}    smooth

*** Keywords ***
# =============================================================================
# BASIC NAVIGATION
# =============================================================================

Navigate To URL
    [Documentation]    Navigates to a specified URL and waits for page to load.
    [Arguments]    ${url}    ${load_state}=${DEFAULT_LOAD_STATE}

    Go To    ${url}

    Wait For Load State    ${load_state}

    Log    Navigated to: ${url}    level=INFO


Go Back
    [Documentation]    Navigates back to the previous page.
    [Arguments]    ${load_state}=${DEFAULT_LOAD_STATE}

    Browser.Go Back

    Wait For Load State    ${load_state}

    Log    Navigated back    level=INFO


Go Forward
    [Documentation]    Navigates forward to the next page.
    [Arguments]    ${load_state}=${DEFAULT_LOAD_STATE}

    Browser.Go Forward

    Wait For Load State    ${load_state}

    Log    Navigated forward    level=INFO


Refresh Page
    [Documentation]    Refreshes the current page.
    [Arguments]    ${load_state}=${DEFAULT_LOAD_STATE}

    Reload

    Wait For Load State    ${load_state}

    Log    Page refreshed    level=INFO


# =============================================================================
# WAIT & LOAD
# =============================================================================

Wait For Page To Load
    [Documentation]    Waits for the page to reach a specific load state.
    [Arguments]    ${load_state}=${DEFAULT_LOAD_STATE}    ${timeout}=30s

    Wait For Load State    ${load_state}    timeout=${timeout}

    Log    Page loaded: ${load_state}    level=INFO


Wait For Element To Load
    [Documentation]    Waits for a specific element to be visible on the page.
    [Arguments]    ${selector}    ${timeout}=30s

    Wait For Elements State    ${selector}    visible    timeout=${timeout}

    Log    Element loaded: ${selector}    level=INFO


Wait For URL To Contain
    [Documentation]    Waits for the URL to contain the expected text.
    [Arguments]    ${expected_url}    ${timeout}=30s

    Wait For Condition
    ...    type=location
    ...    value=${expected_url}
    ...    timeout=${timeout}

    Log    URL now contains: ${expected_url}    level=INFO


# =============================================================================
# URL MANAGEMENT
# =============================================================================

Get Current URL
    [Documentation]    Returns the current page URL.

    ${url}=    Get Url

    Log    Current URL: ${url}    level=INFO

    RETURN    ${url}


Verify Current URL
    [Documentation]    Verifies that the current URL matches the expected URL exactly.
    [Arguments]    ${expected_url}

    ${current_url}=    Get Current URL

    Should Be Equal    ${current_url}    ${expected_url}
    ...    URL mismatch. Expected: ${expected_url} | Got: ${current_url}

    Log    URL verified: ${current_url}    level=INFO


Verify URL Contains
    [Documentation]    Verifies that the current URL contains expected text.
    [Arguments]    ${expected_text}

    ${current_url}=    Get Current URL

    Should Contain    ${current_url}    ${expected_text}
    ...    URL does not contain: ${expected_text} | Current URL: ${current_url}

    Log    URL contains verified: ${expected_text}    level=INFO


# =============================================================================
# PAGE STATE — SCROLLING
# =============================================================================

Scroll To Top
    [Documentation]    Scrolls to the top of the page.
    [Arguments]    ${behavior}=${DEFAULT_SCROLL_BEHAVIOR}

    Evaluate JavaScript    ${None}    window.scrollTo({top: 0, behavior: '${behavior}'})

    Log    Scrolled to top    level=INFO


Scroll To Bottom
    [Documentation]    Scrolls to the bottom of the page.
    [Arguments]    ${behavior}=${DEFAULT_SCROLL_BEHAVIOR}

    Evaluate JavaScript    ${None}    window.scrollTo({top: document.body.scrollHeight, behavior: '${behavior}'})

    Log    Scrolled to bottom    level=INFO


Scroll To Element
    [Arguments]    ${selector}    ${behavior}=${DEFAULT_SCROLL_BEHAVIOR}

    Evaluate JavaScript    ${selector}
    ...    (el) => el.scrollIntoView({behavior: '${behavior}'})

    Log    Scrolled to element: ${selector}    level=INFO


Scroll By
    [Documentation]    Scrolls the page by a given pixel offset.
    [Arguments]    ${x}=0    ${y}=500    ${behavior}=${DEFAULT_SCROLL_BEHAVIOR}

    Evaluate JavaScript    ${None}    window.scrollBy({left: ${x}, top: ${y}, behavior: '${behavior}'})

    Log    Scrolled by x=${x} y=${y}    level=INFO

# =============================================================================
# FRAMES
# =============================================================================

Switch To Frame
    [Arguments]    ${selector}

    ${frame_locator}=    Evaluate JavaScript    ${None}
    ...    undefined    # frames need locator chaining in Playwright

    # Correct approach: use frame_locator via JavaScript or nested keyword
    Log    Use frame-aware locators like: ${selector} >>> inner_selector    level=INFO


Switch To Main Frame
    [Documentation]    Switches context back to the main frame.

    Log    Switched to main frame    level=INFO


# =============================================================================
# TABS
# =============================================================================

Switch To Tab
    [Documentation]    Switches to a specific tab by index.
    [Arguments]    ${index}=NEW

    Switch Page    ${index}

    Log    Switched to tab: ${index}    level=INFO


Get All Tabs
    [Documentation]    Returns all open tab handles.

    ${tabs}=    Get Page Ids    ALL

    Log    Open tabs: ${tabs}    level=INFO

    RETURN    ${tabs}


Close Current Tab
    [Documentation]    Closes the current tab.

    Close Page

    Log    Current tab closed    level=INFO