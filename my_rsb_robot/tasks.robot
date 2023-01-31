*** Settings ***
Documentation       The robot is intended to look up the person number in hitta.se and send an email if it finds a new match.

Library             RPA.Browser.Selenium    auto_close=${FALSE}


*** Variables ***
${NUMBER OF PERSONS}    1
${POPUP COOKIES}        FALSE


*** Tasks ***
The robot is intended to look up the person number in hitta.se and send an email if it finds a new match.
    Open the internet website
    Input name
    Get Number of Persons


*** Keywords ***
Open the internet website
    Open Available Browser    https://www.hitta.se/
    ${POPUP COOKIES} = Does Page Contain Button    modalConfirmBtn
    IF    ${POPUP_COOKIES} == TRUE    Click Button    modalConfirmBtn
    # Wait Until Page Contains Element    id:sokHittaInput

Input name
    Input Text    sokHittaInput    Nicolas Viola
    Click Button    sokHittaBtn

Get Number of Persons
    ${NUMBER OF PERSONS}=    Get Text    //*[@id="search-results-cmp"]/div/div[1]/div/div[1]/nav/a[2]
    Log    ${NUMBER OF PERSONS}
