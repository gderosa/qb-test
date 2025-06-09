*** Settings ***
Library         REST    url=https://restful-booker.herokuapp.com/    loglevel=INFO

*** Variables ***
${USERNAME}       admin
${PASSWORD}       password123
${TOKEN}          None

*** Test Cases ***
Authenticate and retrieve token
    POST    /auth    body={"username": "${USERNAME}", "password": "${PASSWORD}"}

    ${token_value}=    Output    $.token
    Set Suite Variable    ${TOKEN}    ${token_value}

    Log To Console    ${TOKEN}

Show Token is preserved
    Log To Console    ${TOKEN}

Get Bookings
    GET    /booking    headers={"Cookie": "token=${TOKEN}"}
    Array    response body
    Output
    Integer    $[0].bookingid
   