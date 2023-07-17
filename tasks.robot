*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.PDF
Library             RPA.Tables
Library             OperatingSystem
Library             RPA.FileSystem
Library             RPA.Archive


*** Tasks ***
Order robots from site
    Open robot order site
    Download, read and return results of Excel sheet
    Export PDFs to ZIP file

*** Keywords ***
Open robot order site
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download, read and return results of Excel sheet
    Download    https://robotsparebinindustries.com/orders.csv
    ${orders}=    Read table from CSV    orders.csv    headers=True
    Close Workbook
    FOR    ${order}    IN    @{orders}
        Fill form for one Robot, save PDF file and submit    ${order}
    END

Fill form for one Robot, save PDF file and submit
    [Arguments]    ${order}
    Sleep    1 second
    Click Button    OK
    Select From List By Value    head    ${order}[Head]
    Click Button    id-body-${order}[Body]
    Input Text    class:form-control    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Wait Until Element Is Visible    order
    Wait Until Element Is Visible    preview

    Click Button    preview
    Click Button    order
    Sleep    1 second

    ${order_not_work}=    Does Page Contain Element    //div[@class="alert alert-danger"]
    WHILE    ${order_not_work} == ${True}
        Sleep    1 second
        Click Button    order
        ${order_not_work}=    Does Page Contain Element    //div[@class="alert alert-danger"]
    END
    Sleep    1 second
    Screenshot and save as PDF    ${order}
    Click Button    order-another

Screenshot and save as PDF
    [Arguments]    ${order}
    ${receipt_element}=    Get Element Attribute    //div[@class="alert alert-success"]    outerHTML
    Html To Pdf    ${receipt_element}    C://Users//yousuf.sajjad//OneDrive - LLA//Desktop//order_robot//receipts${/}${order}[Order number].pdf
    Screenshot    //div[@id="robot-preview-image"]    C://Users//yousuf.sajjad//OneDrive - LLA//Desktop//order_robot//receipts${/}preview.png
    ${preview}=    Find Files    C://Users//yousuf.sajjad//OneDrive - LLA//Desktop//order_robot//receipts${/}preview.png
    Add Files To Pdf    ${preview}    C://Users//yousuf.sajjad//OneDrive - LLA//Desktop//order_robot//receipts${/}${order}[Order number].pdf    append=${True}
    
Export PDFs to ZIP file
    Archive Folder With Zip    receipts    receipt_files.zip
    