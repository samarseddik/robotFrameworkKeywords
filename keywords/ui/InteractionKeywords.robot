*** Settings ***
Documentation    Reusable keywords for UI element interactions.
...              Handles clicks, keyboard, mouse, select, checkbox, file upload and wait actions.
...              Generic and project-agnostic — works with any web application.
Library          Browser
Library          BuiltIn
Resource         NavigationKeywords.robot
Resource         CommonUI.robot

*** Variables ***
${DEFAULT_TIMEOUT}      30s
${DEFAULT_DELAY}        0ms

*** Keywords ***
# =============================================================================
# CLICK ACTIONS
# =============================================================================

Click Element
    [Documentation]    Clicks on a specified element.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Browser.Click    ${selector}

    Log    Clicked element: ${selector}    level=INFO

Double Click Element
    [Documentation]    Double clicks on a specified element.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Click    ${selector}
    Click    ${selector}

    Log    Double clicked element: ${selector}    level=INFO


Right Click Element
    [Documentation]    Right clicks on a specified element.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Click    ${selector}    button=right

    Log    Right clicked element: ${selector}    level=INFO


Click At Coordinates
    [Documentation]    Clicks at specific x y coordinates on the page.
    [Arguments]    ${x}    ${y}

    Mouse Button    click    ${x}    ${y}

    Log    Clicked at coordinates: x=${x} y=${y}    level=INFO


# =============================================================================
# KEYBOARD ACTIONS
# =============================================================================

Type Text
    [Documentation]    Types text into a specified element.
    [Arguments]    ${selector}    ${text}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Fill Text    ${selector}    ${text}

    Log    Typed text into: ${selector}    level=INFO


Clear And Type Text
    [Documentation]    Clears existing text and types new text into an element.
    [Arguments]    ${selector}    ${text}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Clear Text    ${selector}
    Fill Text    ${selector}    ${text}

    Log    Cleared and typed text into: ${selector}    level=INFO


Press Key
    [Documentation]    Presses a specific keyboard key on an element.
    [Arguments]    ${selector}    ${key}

    Keyboard Key    press    ${key}

    Log    Pressed key: ${key} on ${selector}    level=INFO


Press Enter
    [Documentation]    Presses the Enter key.
    [Arguments]    ${selector}=${None}

    Keyboard Key    press    Enter

    Log    Pressed Enter    level=INFO


Press Escape
    [Documentation]    Presses the Escape key.

    Keyboard Key    press    Escape

    Log    Pressed Escape    level=INFO


Press Tab
    [Documentation]    Presses the Tab key.

    Keyboard Key    press    Tab

    Log    Pressed Tab    level=INFO


# =============================================================================
# MOUSE ACTIONS
# =============================================================================

Hover Over Element
    [Documentation]    Hovers the mouse over a specified element.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Hover    ${selector}

    Log    Hovered over element: ${selector}    level=INFO


Drag And Drop
    [Documentation]    Drags an element and drops it onto another element.
    [Arguments]    ${source_selector}    ${target_selector}

    Drag And Drop    ${source_selector}    ${target_selector}

    Log    Dragged ${source_selector} to ${target_selector}    level=INFO


Mouse Down
    [Documentation]    Presses and holds the mouse button on an element.
    [Arguments]    ${selector}

    Mouse Button    down    ${selector}

    Log    Mouse down on: ${selector}    level=INFO


Mouse Up
    [Documentation]    Releases the mouse button on an element.
    [Arguments]    ${selector}

    Mouse Button    up    ${selector}

    Log    Mouse up on: ${selector}    level=INFO


# =============================================================================
# FOCUS ACTIONS
# =============================================================================

Focus Element
    [Documentation]    Sets focus on a specified element.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Focus    ${selector}

    Log    Focused element: ${selector}    level=INFO


Blur Element
    [Documentation]    Removes focus from a specified element.
    [Arguments]    ${selector}

    Evaluate JavaScript    ${selector}    document.querySelector('${selector}').blur()

    Log    Blurred element: ${selector}    level=INFO


# =============================================================================
# SELECT ACTIONS
# =============================================================================

Select Option By Value
    [Documentation]    Selects an option from a dropdown by its value.
    [Arguments]    ${selector}    ${value}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Select Options By    ${selector}    value    ${value}

    Log    Selected option by value: ${value} in ${selector}    level=INFO


Select Option By Label
    [Documentation]    Selects an option from a dropdown by its visible label.
    [Arguments]    ${selector}    ${label}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Select Options By    ${selector}    label    ${label}

    Log    Selected option by label: ${label} in ${selector}    level=INFO


Select Option By Index
    [Documentation]    Selects an option from a dropdown by its index.
    [Arguments]    ${selector}    ${index}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Select Options By    ${selector}    index    ${index}

    Log    Selected option by index: ${index} in ${selector}    level=INFO


Get Selected Option
    [Documentation]    Returns the currently selected option value from a dropdown.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    ${value}=    Get Selected Options    ${selector}    value

    Log    Selected option value: ${value}    level=INFO

    RETURN    ${value}


# =============================================================================
# CHECKBOX & RADIO
# =============================================================================

Check Checkbox
    [Documentation]    Checks a checkbox if it is not already checked.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Check Checkbox    ${selector}

    Log    Checkbox checked: ${selector}    level=INFO


Uncheck Checkbox
    [Documentation]    Unchecks a checkbox if it is checked.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Uncheck Checkbox    ${selector}

    Log    Checkbox unchecked: ${selector}    level=INFO


Select Radio Button
    [Documentation]    Selects a radio button element.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Check Checkbox    ${selector}

    Log    Radio button selected: ${selector}    level=INFO


Get Checkbox State
    [Documentation]    Returns the checked state of a checkbox.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    ${state}=    Get Checkbox State    ${selector}

    Log    Checkbox state: ${state}    level=INFO

    RETURN    ${state}


# =============================================================================
# FILE UPLOAD
# =============================================================================

Upload File
    [Documentation]    Uploads a file using a file input element.
    [Arguments]    ${selector}    ${file_path}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Upload File By Selector    ${selector}    ${file_path}

    Log    File uploaded: ${file_path} via ${selector}    level=INFO


Get Upload File Name
    [Documentation]    Returns the name of the uploaded file from a file input.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    ${value}=    Get Property    ${selector}    value

    Log    Uploaded file name: ${value}    level=INFO

    RETURN    ${value}


# =============================================================================
# WAIT ACTIONS
# =============================================================================

Wait For Element
    [Documentation]    Waits for an element to be visible on the page.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    visible    timeout=${timeout}

    Log    Element visible: ${selector}    level=INFO


Wait For Element To Be Enabled
    [Documentation]    Waits for an element to be enabled and interactable.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    enabled    timeout=${timeout}

    Log    Element enabled: ${selector}    level=INFO


Wait For Element To Disappear
    [Documentation]    Waits for an element to disappear from the page.
    [Arguments]    ${selector}    ${timeout}=${DEFAULT_TIMEOUT}

    Wait For Elements State    ${selector}    hidden    timeout=${timeout}

    Log    Element disappeared: ${selector}    level=INFO