*** Settings ***
Documentation    Reusable keywords for performance testing and monitoring.
...              Handles page metrics, resource timing and performance validation.
...              Generic and project-agnostic — works with any web application.
Library          Browser
Library          BuiltIn
Library          DateTime
Resource         NetworkKeywords.robot

*** Variables ***
${DEFAULT_MAX_LOAD_TIME}      5000
${DEFAULT_TIMEOUT}            30s

*** Keywords ***
# =============================================================================
# PAGE METRICS
# =============================================================================

Get Page Load Time
    [Documentation]    Returns the total page load time in milliseconds.

    ${load_time}=    Evaluate JavaScript    ${None}
    ...    window.performance.timing.loadEventEnd - window.performance.timing.navigationStart

    Log    Page load time: ${load_time}ms    level=INFO

    RETURN    ${load_time}


Get DOM Content Loaded Time
    [Documentation]    Returns the DOM content loaded time in milliseconds.

    ${dom_time}=    Evaluate JavaScript    ${None}
    ...    window.performance.timing.domContentLoadedEventEnd - window.performance.timing.navigationStart

    Log    DOM content loaded time: ${dom_time}ms    level=INFO

    RETURN    ${dom_time}


Get First Contentful Paint
    [Documentation]    Returns the First Contentful Paint time in milliseconds.

    ${fcp}=    Evaluate JavaScript    ${None}
    ...    JSON.stringify(window.performance.getEntriesByName('first-contentful-paint'))

    Log    First Contentful Paint: ${fcp}    level=INFO

    RETURN    ${fcp}


Get Largest Contentful Paint
    [Documentation]    Returns the Largest Contentful Paint time in milliseconds.

    ${lcp}=    Evaluate JavaScript    ${None}
    ...    JSON.stringify(window.performance.getEntriesByType('largest-contentful-paint'))

    Log    Largest Contentful Paint: ${lcp}    level=INFO

    RETURN    ${lcp}


# =============================================================================
# RESOURCE TIMING
# =============================================================================

Get Resource Load Times
    [Documentation]    Returns load times for all resources on the page.

    ${resources}=    Evaluate JavaScript    ${None}
    ...    JSON.stringify(window.performance.getEntriesByType('resource').map(r => ({name: r.name, duration: r.duration})))

    Log    Resource load times: ${resources}    level=INFO

    RETURN    ${resources}


Get Slow Resources
    [Documentation]    Returns resources that took longer than the specified threshold in ms.
    [Arguments]    ${threshold}=1000

    ${slow}=    Evaluate JavaScript    ${None}
    ...    JSON.stringify(window.performance.getEntriesByType('resource').filter(r => r.duration > ${threshold}).map(r => ({name: r.name, duration: r.duration})))

    Log    Slow resources (>${threshold}ms): ${slow}    level=INFO

    RETURN    ${slow}


# =============================================================================
# PERFORMANCE VALIDATION
# =============================================================================

Verify Page Load Time
    [Documentation]    Verifies that the page load time is within the acceptable limit.
    [Arguments]    ${max_load_time}=${DEFAULT_MAX_LOAD_TIME}

    ${load_time}=    Get Page Load Time

    Should Be True    ${load_time} <= ${max_load_time}
    ...    Page load time exceeded limit. Load time: ${load_time}ms | Max: ${max_load_time}ms

    Log    Page load time verified: ${load_time}ms <= ${max_load_time}ms    level=INFO


Verify Resource Load Time
    [Documentation]    Verifies that a specific resource loads within the acceptable limit.
    [Arguments]    ${resource_name}    ${max_load_time}=${DEFAULT_MAX_LOAD_TIME}

    ${duration}=    Evaluate JavaScript    ${None}
    ...    (() => { const r = window.performance.getEntriesByType('resource').find(r => r.name.includes('${resource_name}')); return r ? r.duration : -1; })()

    Should Be True    ${duration} >= 0
    ...    Resource not found: ${resource_name}

    Should Be True    ${duration} <= ${max_load_time}
    ...    Resource load time exceeded. Duration: ${duration}ms | Max: ${max_load_time}ms

    Log    Resource load time verified: ${resource_name} = ${duration}ms    level=INFO


# =============================================================================
# CUSTOM METRICS
# =============================================================================

Start Performance Timer
    [Documentation]    Starts a performance timer and stores the start time.
    [Arguments]    ${timer_name}=default

    ${start_time}=    Get Current Date    result_format=epoch

    Set Suite Variable    ${TIMER_${timer_name}_START}    ${start_time}

    Log    Performance timer started: ${timer_name}    level=INFO

    RETURN    ${start_time}


Stop Performance Timer
    [Documentation]    Stops a performance timer and returns the elapsed time in seconds.
    [Arguments]    ${timer_name}=default

    ${end_time}=    Get Current Date    result_format=epoch
    ${start_time}=    Set Variable    ${TIMER_${timer_name}_START}
    ${elapsed}=    Evaluate    round(${end_time} - ${start_time}, 3)

    Set Suite Variable    ${TIMER_${timer_name}_ELAPSED}    ${elapsed}

    Log    Performance timer stopped: ${timer_name} | Elapsed: ${elapsed}s    level=INFO

    RETURN    ${elapsed}


Get Elapsed Time
    [Documentation]    Returns the elapsed time of a previously stopped timer.
    [Arguments]    ${timer_name}=default

    ${elapsed}=    Set Variable    ${TIMER_${timer_name}_ELAPSED}

    Log    Elapsed time for ${timer_name}: ${elapsed}s    level=INFO

    RETURN    ${elapsed}