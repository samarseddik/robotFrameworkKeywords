*** Settings ***
Documentation    Reusable keywords for form handling.
...              Handles form filling, validation, state and login operations.
...              Generic and project-agnostic — works with any web application.
Library          Browser
Library          BuiltIn
Library          Collections
Resource         InteractionKeywords.robot

*** Variables ***
${DEFAULT_TIMEOUT}      30s

*** Keywords ***
# =============================================================================
# FORM ACTIONS
# =============================================================================

Fill Form Field
    [Documentation]    Fills a form field with a specified value.
    [Arguments]    ${selector}    ${value}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Fill Text    ${selector}    ${value}

    Log    Filled form field: ${selector} with value: ${value}    level=INFO


Submit Form
    [Documentation]    Submits a form by clicking the submit button.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Click    ${selector}

    Log    Form submitted via: ${selector}    level=INFO


Clear Form Field
    [Documentation]    Clears the value of a form field.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Clear Text    ${selector}

    Log    Form field cleared: ${selector}    level=INFO


Get Form Field Value
    [Documentation]    Returns the current value of a form field.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    ${value}=    Get Property    ${selector}    value

    Log    Form field value: ${value}    level=INFO

    RETURN    ${value}


# =============================================================================
# FORM VALIDATION
# =============================================================================

Verify Form Field Value
    [Documentation]    Verifies that a form field contains the expected value.
    [Arguments]    ${selector}    ${expected_value}    ${timeout}=${DEFAULT_TIMEOUT}

    ${actual_value}=    Get Form Field Value    ${selector}    ${timeout}

    Should Be Equal    ${actual_value}    ${expected_value}
    ...    Field value mismatch. Expected: ${expected_value} | Got: ${actual_value}

    Log    Form field value verified: ${expected_value}    level=INFO


Verify Form Field Is Empty
    [Documentation]    Verifies that a form field is empty.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    ${value}=    Get Form Field Value    ${selector}    ${timeout}

    Should Be Empty    ${value}
    ...    Form field is not empty. Current value: ${value}

    Log    Form field is empty: ${selector}    level=INFO


Verify Form Field Is Required
    [Documentation]    Verifies that a form field is required by clearing it,
    ...                submitting the form and checking for a validation message.
    [Arguments]    ${field_selector}    ${submit_selector}    ${error_selector}
    ...            ${timeout}=${DEFAULT_TIMEOUT}

    Clear Form Field    ${field_selector}
    Click    ${submit_selector}
    Wait For Elements State    ${error_selector}    visible    timeout=${timeout}

    Log    Field '${field_selector}' is required — validation message appeared    level=INFO


Verify Form Has Error
    [Documentation]    Verifies that a form error message is visible.
    [Arguments]    ${error_selector}    ${expected_message}=${EMPTY}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${error_selector}    visible    timeout=${timeout}

    Run Keyword If    '${expected_message}' != '${EMPTY}'
    ...    Get Text    ${error_selector}

    Log    Form error verified: ${error_selector}    level=INFO


# =============================================================================
# FORM STATE
# =============================================================================

Get Form Field State
    [Documentation]    Returns the state of a form field (enabled/disabled/visible/hidden).
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    attached    timeout=${timeout}
    ${enabled}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${selector}    enabled    timeout=2s
    ${visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${selector}    visible    timeout=2s

    ${state}=    Set Variable If
    ...    ${enabled} and ${visible}    enabled-visible
    ...    ${enabled} and not ${visible}    enabled-hidden
    ...    not ${enabled} and ${visible}    disabled-visible
    ...    disabled-hidden

    Log    Form field state: ${state}    level=INFO

    RETURN    ${state}


Verify Form Field Is Enabled
    [Documentation]    Verifies that a form field is enabled.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    enabled    timeout=${timeout}

    Log    Form field is enabled: ${selector}    level=INFO


Verify Form Field Is Disabled
    [Documentation]    Verifies that a form field is disabled.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    disabled    timeout=${timeout}

    Log    Form field is disabled: ${selector}    level=INFO


Verify Form Field Is Visible
    [Documentation]    Verifies that a form field is visible on the page.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}

    Log    Form field is visible: ${selector}    level=INFO


# =============================================================================
# FORM DATA
# =============================================================================

Fill Form With Data
    [Documentation]    Fills multiple form fields using a dictionary of selector:value pairs.
    [Arguments]    &{form_data}

    FOR    ${selector}    IN    @{form_data}
        ${value}=    Get From Dictionary    ${form_data}    ${selector}
        Fill Form Field    ${selector}    ${value}
    END

    Log    Form filled with ${form_data.__len__()} fields    level=INFO


Clear All Form Fields
    [Documentation]    Clears all specified form fields.
    [Arguments]    @{selectors}

    FOR    ${selector}    IN    @{selectors}
        Clear Form Field    ${selector}
    END

    Log    Cleared ${selectors.__len__()} form fields    level=INFO


Get All Form Field Values
    [Documentation]    Returns values of all specified form fields as a dictionary.
    [Arguments]    @{selectors}

    ${values}=    Create Dictionary

    FOR    ${selector}    IN    @{selectors}
        ${value}=    Get Form Field Value    ${selector}
        Set To Dictionary    ${values}    ${selector}    ${value}
    END

    Log    Retrieved values for ${selectors.__len__()} fields    level=INFO

    RETURN    ${values}


# =============================================================================
# LOGIN FORM
# =============================================================================

Fill Login Form
    [Documentation]    Fills the login form with email and password.
    [Arguments]    ${email}    ${password}
    ...            ${email_selector}=input[type="email"]
    ...            ${password_selector}=input[type="password"]
    
    Clear Text    ${email_selector}
    Clear Text    ${password_selector}
    Fill Form Field    ${email_selector}    ${email}
    Fill Form Field    ${password_selector}    ${password}

    Log    Login form filled for: ${email}    level=INFO


Submit Login Form
    [Documentation]    Submits the login form.
    [Arguments]    ${submit_selector}=button[type="submit"]

    Submit Form    ${submit_selector}

    Log    Login form submitted    level=INFO


Verify Login Success
    [Documentation]    Verifies that login was successful by checking URL or element.
    [Arguments]    ${success_indicator}    ${timeout}=15s

    Wait For Elements State    ${success_indicator}    visible    timeout=${timeout}

    Log    Login successful — element visible: ${success_indicator}    level=INFO


Verify Login Failure
    [Documentation]    Verifies that login failed by checking error message visibility.
    [Arguments]    ${error_selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${error_selector}    visible    timeout=${timeout}

    Log    Login failure verified — error visible: ${error_selector}    level=INFO