*** Settings ***
Documentation    Reusable keywords for UI element and page validation.
...              Handles visibility, text, attribute, state and style assertions.
...              Generic and project-agnostic — works with any web application.
Library          Browser
Library          BuiltIn
Resource         FormKeywords.robot

*** Variables ***
${DEFAULT_TIMEOUT}      30s

*** Keywords ***
# =============================================================================
# VISIBILITY VALIDATION
# =============================================================================

Verify Element Is Visible
    [Documentation]    Verifies that an element is visible on the page.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}

    Log    Element is visible: ${selector}    level=INFO


Verify Element Is Hidden
    [Documentation]    Verifies that an element is hidden on the page.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    hidden    timeout=${timeout}

    Log    Element is hidden: ${selector}    level=INFO


Verify Element Exists
    [Documentation]    Verifies that an element exists in the DOM.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    attached    timeout=${timeout}

    Log    Element exists: ${selector}    level=INFO


Verify Element Does Not Exist
    [Documentation]    Verifies that an element does not exist in the DOM.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    detached    timeout=${timeout}

    Log    Element does not exist: ${selector}    level=INFO


# =============================================================================
# TEXT VALIDATION
# =============================================================================

Get Element Text
    [Documentation]    Returns the text content of an element.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    ${text}=    Get Text    ${selector}

    Log    Element text: ${text}    level=INFO

    RETURN    ${text}


Verify Element Text
    [Documentation]    Verifies that an element's text matches exactly.
    [Arguments]    ${selector}    ${expected_text}    ${timeout}=${DEFAULT_TIMEOUT}

    ${actual_text}=    Get Element Text    ${selector}    ${timeout}

    Should Be Equal    ${actual_text}    ${expected_text}
    ...    Text mismatch. Expected: ${expected_text} | Got: ${actual_text}

    Log    Element text verified: ${expected_text}    level=INFO


Verify Element Text Contains
    [Documentation]    Verifies that an element's text contains expected text.
    [Arguments]    ${selector}    ${expected_text}    ${timeout}=${DEFAULT_TIMEOUT}

    ${actual_text}=    Get Element Text    ${selector}    ${timeout}

    Should Contain    ${actual_text}    ${expected_text}
    ...    Text does not contain: ${expected_text} | Got: ${actual_text}

    Log    Element text contains verified: ${expected_text}    level=INFO


Verify Element Text Matches
    [Documentation]    Verifies that an element's text matches a regular expression.
    [Arguments]    ${selector}    ${pattern}    ${timeout}=${DEFAULT_TIMEOUT}

    ${actual_text}=    Get Element Text    ${selector}    ${timeout}

    Should Match Regexp    ${actual_text}    ${pattern}
    ...    Text does not match pattern: ${pattern} | Got: ${actual_text}

    Log    Element text matches pattern: ${pattern}    level=INFO


# =============================================================================
# ATTRIBUTE VALIDATION
# =============================================================================

Get Element Attribute
    [Documentation]    Returns the value of a specified attribute on an element.
    [Arguments]    ${selector}    ${attribute}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    attached    timeout=${timeout}
    ${value}=    Get Attribute    ${selector}    ${attribute}

    Log    Element attribute ${attribute}: ${value}    level=INFO

    RETURN    ${value}


Verify Element Attribute
    [Documentation]    Verifies that an element's attribute has the expected value.
    [Arguments]    ${selector}    ${attribute}    ${expected_value}    ${timeout}=${DEFAULT_TIMEOUT}

    ${actual_value}=    Get Element Attribute    ${selector}    ${attribute}    ${timeout}

    Should Be Equal    ${actual_value}    ${expected_value}
    ...    Attribute mismatch. Expected: ${expected_value} | Got: ${actual_value}

    Log    Element attribute verified: ${attribute}=${expected_value}    level=INFO


Verify Element Has Class
    [Documentation]    Verifies that an element has a specific CSS class.
    [Arguments]    ${selector}    ${class_name}    ${timeout}=${DEFAULT_TIMEOUT}

    ${classes}=    Get Element Attribute    ${selector}    class    ${timeout}

    Should Contain    ${classes}    ${class_name}
    ...    Element does not have class: ${class_name} | Got classes: ${classes}

    Log    Element has class verified: ${class_name}    level=INFO


Verify Element Count
    [Documentation]    Verifies that a specific number of elements match the selector.
    [Arguments]    ${selector}    ${expected_count}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    attached    timeout=${timeout}
    ${count}=    Get Element Count    ${selector}

    Should Be Equal As Integers    ${count}    ${expected_count}
    ...    Element count mismatch. Expected: ${expected_count} | Got: ${count}

    Log    Element count verified: ${expected_count}    level=INFO


# =============================================================================
# STATE VALIDATION
# =============================================================================

Verify Element Is Enabled
    [Documentation]    Verifies that an element is enabled.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    enabled    timeout=${timeout}

    Log    Element is enabled: ${selector}    level=INFO


Verify Element Is Disabled
    [Documentation]    Verifies that an element is disabled.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    disabled    timeout=${timeout}

    Log    Element is disabled: ${selector}    level=INFO


Verify Element Is Selected
    [Documentation]    Verifies that a checkbox or radio element is selected/checked.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    checked    timeout=${timeout}

    Log    Element is selected: ${selector}    level=INFO


# =============================================================================
# PAGE VALIDATION
# =============================================================================

Verify Page Title
    [Documentation]    Verifies that the page title matches exactly.
    [Arguments]    ${expected_title}

    ${actual_title}=    Get Title

    Should Be Equal    ${actual_title}    ${expected_title}
    ...    Title mismatch. Expected: ${expected_title} | Got: ${actual_title}

    Log    Page title verified: ${expected_title}    level=INFO


Verify Page Title Contains
    [Documentation]    Verifies that the page title contains expected text.
    [Arguments]    ${expected_text}

    ${actual_title}=    Get Title

    Should Contain    ${actual_title}    ${expected_text}
    ...    Title does not contain: ${expected_text} | Got: ${actual_title}

    Log    Page title contains verified: ${expected_text}    level=INFO


Verify Page URL
    [Documentation]    Verifies that the page URL matches exactly.
    [Arguments]    ${expected_url}

    ${actual_url}=    Get Url

    Should Be Equal    ${actual_url}    ${expected_url}
    ...    URL mismatch. Expected: ${expected_url} | Got: ${actual_url}

    Log    Page URL verified: ${expected_url}    level=INFO


Verify Page URL Contains
    [Documentation]    Verifies that the page URL contains expected text.
    [Arguments]    ${expected_text}

    ${actual_url}=    Get Url

    Should Contain    ${actual_url}    ${expected_text}
    ...    URL does not contain: ${expected_text} | Got: ${actual_url}

    Log    Page URL contains verified: ${expected_text}    level=INFO


# =============================================================================
# STYLE VALIDATION
# =============================================================================

Get Element CSS Property
    [Documentation]    Returns the value of a CSS property on an element.
    [Arguments]    ${selector}    ${property}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    ${value}=    Get Style    ${selector}    ${property}

    Log    Element CSS property ${property}: ${value}    level=INFO

    RETURN    ${value}


Verify Element CSS Property
    [Documentation]    Verifies that an element's CSS property has the expected value.
    [Arguments]    ${selector}    ${property}    ${expected_value}    ${timeout}=${DEFAULT_TIMEOUT}

    ${actual_value}=    Get Element CSS Property    ${selector}    ${property}    ${timeout}

    Should Be Equal    ${actual_value}    ${expected_value}
    ...    CSS property mismatch. Expected: ${expected_value} | Got: ${actual_value}

    Log    CSS property verified: ${property}=${expected_value}    level=INFO