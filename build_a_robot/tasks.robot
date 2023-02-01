*** Settings ***
Documentation       This robot is for Certification Level II of Robocorp. Its purpose
...                 is to order robots in the website based on a CSV file, then take
...                 take a Screenshot of the requested robot and create a pdf receipt
...                 with the order and the image. Finally creates a zip file with all
...                 created receipts.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Tables
Library             RPA.Archive
Library             RPA.FileSystem
Library             RPA.Robocorp.Vault
Library             RPA.Dialogs
Library             RPA.Robocorp.Vault


*** Tasks ***
This is the workflow for Requesting robots
    ${CSV_Path}=    Input from Dialog
    ${URL}=    Get Secret    robotOrderURL
    # PopUp URL    ${URL}[value]
    Open the website    ${URL}[value]
    Download csv    ${CSV_Path}
    ${orders}=    Read table from CSV    orders.csv
    FOR    ${row}    IN    @{orders}
        Try to close the modal
        Fill in the form    ${row}
        Get preview image    ${row}[Order number]
        Wait Until Keyword Succeeds    5x    3s    Submit the order
        ${pdf}=    Store receipt as PDF    ${row}[Order number]
        Click to create new robot
    END
    ZIP Receipts
    [Teardown]    Clean up and close


*** Keywords ***
Open the website
    [Arguments]    ${url}
    Open Available Browser    ${url}    maximized=True
    Try to close the modal

Download csv
    [Arguments]    ${path}
    Download    ${path}    overwrite=True

Fill in the form
    [Arguments]    ${request}
    Select From List By Value    id:head    ${request}[Head]
    Select Radio Button    body    ${request}[Body]
    Input Text    css:input[class="form-control"]    ${request}[Legs]
    Input Text    id:address    ${request}[Address]

Get preview image
    [Arguments]    ${order_nr}
    Click Button    id:preview
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}robots${/}${order_nr}.png

Submit the order
    Click Button    id:order
    Wait Until Page Contains Element    id:order-another
    Page Should Contain Element    id:order-another

Store receipt as PDF
    [Arguments]    ${order_nr}
    Wait Until Element Is Visible    id:order-another
    ${order_receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_receipt_html}    ${OUTPUT_DIR}${/}receipts${/}${order_nr}.pdf
    ${add}=    Create list
    ...    ${OUTPUT_DIR}${/}receipts${/}${order_nr}.pdf
    ...    ${OUTPUT_DIR}${/}robots${/}${order_nr}.png
    Add Files To Pdf    ${add}    target_document=${OUTPUT_DIR}${/}receipts${/}${order_nr}.pdf

 Click to create new robot
    Click Button    id:order-another

Try to close the modal
    TRY
        Click Button    I guess so...
    EXCEPT
        Log    No pop up present to click
    END

ZiP Receipts
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}${/}receipts
    ...    ${OUTPUT_DIR}${/}results.zip

Clean up and close
    Empty Directory    ${OUTPUT_DIR}${/}robots
    Empty Directory    ${OUTPUT_DIR}${/}receipts
    Close Browser

Input from Dialog
    Add heading    URL to download orders CSV file
    Add text input    URL    label=URL

    ${result}=    Run dialog
    RETURN    ${result.URL}

# PopUp URL
#    [Arguments]    ${URL}
#    Add heading    URL
#    Add icon    Success
#    Add text    ${URL}
#    Run dialog
