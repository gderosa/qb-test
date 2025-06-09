# https://github.com/asyrjasalo/RESTinstance
# https://asyrjasalo.github.io/RESTinstance

# TODO: API URL should be configurable via env var or command line argument or external config file.
# TODO: Same with credentials, plus file permission check, or prompting the user for them.

*** Settings ***
Library         REST    url=https://restful-booker.herokuapp.com/    loglevel=INFO

*** Variables ***
${USERNAME}             admin
${PASSWORD}             password123
${TOKEN}                None
${CREATED_BOOKING_ID}   None

# NOTE: Unfortunate, RESTinstance does not seem to support token auth natively, or it is not documented,
# NOTE: or it is supported in one of its dependencies.
# TODO: investigate.

*** Test Cases ***
Authenticate and retrieve token
    POST    /auth    body={"username": "${USERNAME}", "password": "${PASSWORD}"}

    ${token_value}=     Output      $.token
    Set Suite Variable  ${TOKEN}    ${token_value}

    Log To Console      ${TOKEN}

Show Token is preserved
    Log To Console      ${TOKEN}

# TODO: posibly DRY or use data-driven tests (DataDriver)? -- https://docs.robotframework.org/docs/testcase_styles/datadriven 

# NOTE (2025-06-09): It appears as this deliberately fails with a 418 / I'm a Teapot :
# NOTE (2025-06-09): https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/418 
# NOTE (2025-06-09): But the entry is created, as it appears from the other test cases
Create a Booking
    [Documentation]    Expect a booking to be created with a bookingid.
    POST    /booking        
    ...    body={"firstname": "Sally", "lastname": "Brown", "totalprice": 111, "depositpaid": true, "bookingdates": {"checkin": "2014-03-13", "checkout": "2014-05-21"}, "additionalneeds": "Breakfast"}
    ...    headers={"Cookie": "token=${TOKEN}"}
    
    Integer     response status                                 200
    # Not 201, https://restful-booker.herokuapp.com/apidoc/#api-Booking-CreateBooking
    
    Integer     response body bookingid
    ${CREATED_BOOKING_ID}=    Output    $.bookingid
    Set Suite Variable    ${CREATED_BOOKING_ID}    ${CREATED_BOOKING_ID}
    Log To Console    Created Booking ID: ${CREATED_BOOKING_ID}

    Object      response body booking
    String      response body booking firstname                 Sally
    String      response body booking lastname                  Brown
    Integer     response body booking bookingid
    Integer     response body booking totalprice                111 
    Boolean     response body booking depositpaid               true
    Object      response body booking bookingdates
    String      response body booking bookingdates checkin      2014-03-13
    String      response body booking bookingdates checkout     2014-05-21
    String      response body booking additionalneeds           Breakfast

Get Bookings
    [Documentation]    Expect an Array of bookings, each with an Integer bookingid.
    GET         /booking        headers={"Cookie": "token=${TOKEN}"}

    Integer     response status                                 200
    Array       response body
    Integer     $[0].bookingid

Query Bookings by Firstname and lastname
    [Documentation]    Expect an Array of bookings, each with an Integer bookingid. Filter by firstname and lastname.
    GET         /booking?firstname\=Sally&lastname\=Brown       headers={"Cookie": "token=${TOKEN}"}
    Integer     response status                                 200
    Array       response body
    # The response might be empty. TODO: Add a check for empty response if needed.

Query Bookings by checkin and checkout dates
    [Documentation]    Expect an Array of bookings, each with an Integer bookingid. Filter by checkin and checkout dates.
    GET         /booking?checkin\=2014-03-13&checkout\=2014-05-21        headers={"Cookie": "token=${TOKEN}"}
    Integer     response status                                 200
    Array       response body
    # The response might be empty. TODO: Add a check for empty response if needed.