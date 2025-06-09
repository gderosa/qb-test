# https://github.com/asyrjasalo/RESTinstance
# https://asyrjasalo.github.io/RESTinstance

# TODO: API URL should be configurable via env var or command line argument or external config file.
# TODO: Same with credentials, plus file permission check, or prompting the user for them.

*** Settings ***
Library         REST    url=https://restful-booker.herokuapp.com/    loglevel=TRACE

*** Variables ***
${USERNAME}                 admin
${PASSWORD}                 password123
${TOKEN}                    None
${CREATED_BOOKING_ID}       None
${FIRST_FOUND_BOOKING_ID}   None

# NOTE: Unfortunately, RESTinstance does not seem to support token auth natively, or it is not documented
# NOTE: (or it is supported in one of its dependencies).
# TODO: Investigate.
# NOTE: This is not standard OAuth / JWT, uses cookies etc.

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
# NOTE (2025-06-09): Without getting the created bookingid, more test cases will fail.
Create a Booking
    [Documentation]    Expect a booking to be created with a bookingid.
    POST    /booking
    ...    body={"firstname": "Sally", "lastname": "Brown", "totalprice": 111, "depositpaid": true, "bookingdates": {"checkin": "2014-03-13", "checkout": "2014-05-21"}, "additionalneeds": "Breakfast"}
    ...    headers={"Cookie": "token=${TOKEN}"}

    Integer     response status                                 200     201

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
    ${FIRST_FOUND_BOOKING_ID}=    Output    $[0].bookingid
    Set Suite Variable    ${FIRST_FOUND_BOOKING_ID}    ${FIRST_FOUND_BOOKING_ID}
    Log To Console    First Found Booking ID: ${CREATED_BOOKING_ID}

Query Bookings by Firstname and lastname
    [Documentation]    Expect an Array of bookings, each with an Integer bookingid. Filter by firstname and lastname.
    GET         /booking?firstname\=Sally&lastname\=Brown       headers={"Cookie": "token=${TOKEN}"}

    Integer     response status                                 200
    Array       response body
    Integer     $[0].bookingid
    Object      $[?(@.bookingid\=\=${CREATED_BOOKING_ID})]

Query Bookings by checkin and checkout dates
    [Documentation]    Expect an Array of bookings, each with an Integer bookingid. Filter by checkin and checkout dates.
    GET         /booking?checkin\=2014-03-13&checkout\=2014-05-21        headers={"Cookie": "token=${TOKEN}"}

    Integer     response status                                 200
    Array       response body
    Object      $[?(@.bookingid\=\=${CREATED_BOOKING_ID})]

Get Created Booking
    [Documentation]    Expect a booking with the created bookingid.
    GET         /booking/${CREATED_BOOKING_ID}        headers={"Cookie": "token=${TOKEN}"}
    Integer     response status                                 200
    Object      response body booking
    Integer     response body booking bookingid                 ${CREATED_BOOKING_ID}
    String      response body booking firstname                 Sally
    String      response body booking lastname                  Brown
    Integer     response body booking totalprice                111
    Boolean     response body booking depositpaid               true
    Object      response body booking bookingdates
    String      response body booking bookingdates checkin      2014-03-13
    String      response body booking bookingdates checkout     2014-05-21
    String      response body booking additionalneeds           Breakfast

# Due to 418 fail on creation, let us at least try to get the first found booking.
# But it looks like this also deliberately fails with "I'm a Teapot" :(
Get First Found Booking
    [Documentation]    Expect a booking with the first found bookingid.
    GET         /booking/${FIRST_FOUND_BOOKING_ID}        headers={"Cookie": "token=${TOKEN}"}
    Integer     response status                                 200
    Object      response body booking
    Integer     response body booking bookingid                 ${FIRST_FOUND_BOOKING_ID}
    String      response body booking firstname
    String      response body booking lastname
    Integer     response body booking totalprice
    Boolean     response body booking depositpaid
    Object      response body booking bookingdates
    String      response body booking bookingdates checkin
    String      response body booking bookingdates checkout
    String      response body booking additionalneeds