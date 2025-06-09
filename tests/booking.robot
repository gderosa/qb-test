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

# TODO: DRY or use data-driven tests

Get Bookings
    [Documentation]    Expect an Array of bookings, each with an Integer bookingid.
    GET         /booking        headers={"Cookie": "token=${TOKEN}"}

    Array       response body
    Integer     $[0].bookingid

Query Bookings by Firstname and lastname
    [Documentation]    Expect an Array of bookings, each with an Integer bookingid. Filter by firstname and lastname.
    GET         /booking?firstname\=sally&lastname\=brown        headers={"Cookie": "token=${TOKEN}"}

    Array       response body
    # The response might be empty. TODO: Add a check for empty response if needed.

Query Bookings by checkin and checkout dates
    [Documentation]    Expect an Array of bookings, each with an Integer bookingid. Filter by checkin and checkout dates.
    GET         /booking?checkin\=2014-03-13&checkout\=2014-05-21        headers={"Cookie": "token=${TOKEN}"}

    Array       response body
    # The response might be empty. TODO: Add a check for empty response if needed.