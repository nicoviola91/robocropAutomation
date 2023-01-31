*** Settings ***
Documentation       Maria's robot.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.PDF


*** Tasks ***
This is the workflow for Maria's work
    Open the intranet website
    Log in
    Download the Excel file
    Fill in the form using the data from the Excel file
    Collect the results
    Export the table as PDF
    [Teardown]    Log out and close


*** Keywords ***
Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/    maximized=True

Log in
    Input Text    id:username    maria
    Input Password    id:password    thoushallnotpass
    Submit Form
    Wait Until Page Contains Element    id:sales-form

Download the Excel file
    Download    https://robotsparebinindustries.com/SalesData.xlsx    overwrite=True

Fill in the form using the data from the Excel file
    Open Workbook    SalesData.xlsx
    ${sales_reps}=    Read Worksheet As Table    header=True
    Close Workbook
    FOR    ${sale_rep}    IN    @{sales_reps}
        Fill in and submit the form    ${sale_rep}
    END

Fill in and submit the form
    [Arguments]    ${sales_rep}
    Input Text    id:firstname    ${sales_rep}[First Name]
    Input Text    id:lastname    ${sales_rep}[Last Name]
    Input Text    id:salesresult    ${sales_rep}[Sales]
    Select From List By Value    id:salestarget    ${sales_rep}[Sales Target]
    Click Button    Submit

Collect the results
    Screenshot    css:div.sales-summary    ${OUTPUT_DIR}${/}sales_summary.png

Export the table as PDF
    Wait Until Element Is Visible    id:sales-results
    ${sales_results_html}=    Get Element Attribute    id:sales-results    outerHTML
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}sales_results.pdf

Log out and close
    Click Button    Log out
    Close Browser
