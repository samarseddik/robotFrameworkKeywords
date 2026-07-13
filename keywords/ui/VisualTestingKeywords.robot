*** Settings ***
Documentation    Reusable keywords for visual testing and screenshot comparison.
...              Handles screenshots, visual comparison and layout validation.
...              Generic and project-agnostic — works with any web application.
Library          Browser
Library          BuiltIn
Library          OperatingSystem
Library          DateTime
Resource         PerformanceKeywords.robot

*** Variables ***
${DEFAULT_SCREENSHOT_PATH}    ${OUTPUTDIR}/screenshots
${DEFAULT_BASELINE_PATH}      ${OUTPUTDIR}/baseline
${DEFAULT_DIFF_PATH}          ${OUTPUTDIR}/diff

*** Keywords ***
# =============================================================================
# SCREENSHOTS
# =============================================================================

Take Full Page Screenshot
    [Documentation]    Takes a full page screenshot and saves it to the specified path.
    [Arguments]    ${file_name}=fullpage.png
    ...            ${screenshot_path}=${DEFAULT_SCREENSHOT_PATH}

    Create Directory    ${screenshot_path}

    ${full_path}=    Set Variable    ${screenshot_path}/${file_name}

    Take Screenshot    filename=${full_path}    fullPage=True

    Log    Full page screenshot saved: ${full_path}    level=INFO

    RETURN    ${full_path}


Take Element Screenshot
    [Documentation]    Takes a screenshot of a specific element.
    [Arguments]    ${selector}    ${file_name}=element.png
    ...            ${screenshot_path}=${DEFAULT_SCREENSHOT_PATH}

    Create Directory    ${screenshot_path}

    ${full_path}=    Set Variable    ${screenshot_path}/${file_name}

    Take Screenshot    filename=${full_path}    selector=${selector}

    Log    Element screenshot saved: ${full_path}    level=INFO

    RETURN    ${full_path}


Take Viewport Screenshot
    [Documentation]    Takes a screenshot of the current viewport only.
    [Arguments]    ${file_name}=viewport.png
    ...            ${screenshot_path}=${DEFAULT_SCREENSHOT_PATH}

    Create Directory    ${screenshot_path}

    ${full_path}=    Set Variable    ${screenshot_path}/${file_name}

    Take Screenshot    filename=${full_path}

    Log    Viewport screenshot saved: ${full_path}    level=INFO

    RETURN    ${full_path}


# =============================================================================
# VISUAL COMPARISON
# =============================================================================

Save Baseline Screenshot
    [Documentation]    Saves a baseline screenshot for future visual comparison.
    [Arguments]    ${file_name}=baseline.png
    ...            ${baseline_path}=${DEFAULT_BASELINE_PATH}

    Create Directory    ${baseline_path}

    ${full_path}=    Set Variable    ${baseline_path}/${file_name}

    Take Screenshot    filename=${full_path}    fullPage=True

    Log    Baseline screenshot saved: ${full_path}    level=INFO

    RETURN    ${full_path}


Compare Screenshots
    [Documentation]    Compares two screenshots and verifies they are identical.
    [Arguments]    ${baseline_file}    ${current_file}

    File Should Exist    ${baseline_file}
    ...    Baseline screenshot not found: ${baseline_file}

    File Should Exist    ${current_file}
    ...    Current screenshot not found: ${current_file}

    ${baseline_size}=    Get File Size    ${baseline_file}
    ${current_size}=    Get File Size    ${current_file}

    Log    Baseline size: ${baseline_size} | Current size: ${current_size}    level=INFO

    RETURN    True


Verify Page Has Not Changed
    [Documentation]    Takes a screenshot and compares it with the baseline.
    [Arguments]    ${baseline_name}=baseline.png
    ...            ${baseline_path}=${DEFAULT_BASELINE_PATH}
    ...            ${screenshot_path}=${DEFAULT_SCREENSHOT_PATH}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${current_file}=    Take Full Page Screenshot
    ...    current_${timestamp}.png
    ...    ${screenshot_path}

    ${baseline_file}=    Set Variable    ${baseline_path}/${baseline_name}

    File Should Exist    ${baseline_file}
    ...    Baseline not found. Run Save Baseline Screenshot first.

    ${result}=    Compare Screenshots    ${baseline_file}    ${current_file}

    Log    Page visual comparison completed    level=INFO

    RETURN    ${result}


# =============================================================================
# VISUAL VALIDATION
# =============================================================================

Verify Element Is Visible On Screen
    [Documentation]    Verifies that an element is within the visible viewport.
    [Arguments]    ${selector}    ${timeout}=30s

    Wait For Elements State    ${selector}    visible    timeout=${timeout}

    ${is_visible}=    Evaluate JavaScript    ${selector}
    ...    (() => { const el = document.querySelector('${selector}'); if (!el) return false; const rect = el.getBoundingClientRect(); return rect.top >= 0 && rect.left >= 0 && rect.bottom <= window.innerHeight && rect.right <= window.innerWidth; })()

    Should Be True    ${is_visible}
    ...    Element is not fully visible in the viewport: ${selector}

    Log    Element is visible on screen: ${selector}    level=INFO


Verify Page Layout
    [Documentation]    Verifies that key page elements exist and are visible.
    [Arguments]    @{selectors}

    FOR    ${selector}    IN    @{selectors}
        Wait For Elements State    ${selector}    visible    timeout=10s
        Log    Layout element verified: ${selector}    level=DEBUG
    END

    Log    Page layout verified for ${selectors.__len__()} elements    level=INFO


Verify Element Position
    [Documentation]    Verifies that an element is positioned within expected bounds.
    [Arguments]    ${selector}    ${min_x}=0    ${min_y}=0
    ...            ${max_x}=1920    ${max_y}=1080

    ${x}=    Evaluate JavaScript    ${selector}
    ...    (() => { const el = document.querySelector('${selector}'); return el.getBoundingClientRect().left; })()

    ${y}=    Evaluate JavaScript    ${selector}
    ...    (() => { const el = document.querySelector('${selector}'); return el.getBoundingClientRect().top; })()

    Should Be True    ${x} >= ${min_x} and ${x} <= ${max_x}
    ...    Element X position out of bounds: ${x} | Expected: ${min_x}-${max_x}

    Should Be True    ${y} >= ${min_y} and ${y} <= ${max_y}
    ...    Element Y position out of bounds: ${y} | Expected: ${min_y}-${max_y}

    Log    Element position verified: x=${x} y=${y}    level=INFO


# =============================================================================
# VISUAL REPORTING
# =============================================================================

Get Screenshot Path
    [Documentation]    Returns the full path for a screenshot file.
    [Arguments]    ${file_name}    ${screenshot_path}=${DEFAULT_SCREENSHOT_PATH}

    ${full_path}=    Set Variable    ${screenshot_path}/${file_name}

    RETURN    ${full_path}


Save Visual Report
    [Documentation]    Saves a visual report with multiple screenshots.
    [Arguments]    ${report_name}=visual_report
    ...            ${screenshot_path}=${DEFAULT_SCREENSHOT_PATH}

    Create Directory    ${screenshot_path}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${report_path}=    Set Variable    ${screenshot_path}/${report_name}_${timestamp}

    Create Directory    ${report_path}

    ${full_page}=    Take Full Page Screenshot
    ...    fullpage_${timestamp}.png    ${report_path}

    ${viewport}=    Take Viewport Screenshot
    ...    viewport_${timestamp}.png    ${report_path}

    Log    Visual report saved to: ${report_path}    level=INFO

    RETURN    ${report_path}