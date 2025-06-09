# https://github.com/asyrjasalo/RESTinstance
# https://asyrjasalo.github.io/RESTinstance

# TODO: API URL should be configurable via env var or command line argument or external config file.
# TODO: Same with credentials, plus file permission check, or prompting the user for them.

*** Settings ***
Library         REST    url=https://restful-booker.herokuapp.com/

*** Variables ***
${USERNAME}                 admin
${PASSWORD}                 password123
${TOKEN}                    None
${CREATED_BOOKING_ID}       None
${FIRST_FOUND_BOOKING_ID}   None

# NOTE: Unfortunately, RESTinstance does not seem to support token auth natively, or it is not documented
# NOTE: (or it is supported in one of its dependencies). TODO: Investigate.
# NOTE: This is not standard OAuth / JWT, uses cookies etc.

*** Test Cases ***
Authenticate and retrieve token
    POST    /auth    body={"username": "${USERNAME}", "password": "${PASSWORD}"}

    ${token_value}=     Output      $.token
    Set Suite Variable  ${TOKEN}    ${token_value}

Create a Booking
    [Documentation]    Expect a booking to be created with a bookingid.
    POST    /booking
    ...    body={"firstname": "Sally", "lastname": "Brown", "totalprice": 111, "depositpaid": true, "bookingdates": {"checkin": "2014-03-13", "checkout": "2014-05-21"}, "additionalneeds": "Breakfast"}
    ...    headers={"Cookie": "token=${TOKEN}", "Content-Type": "application/json", "Accept": "application/json"}

    Integer     response status                                 200     201

    Integer     response body bookingid
    ${CREATED_BOOKING_ID}=    Output    $.bookingid
    Set Suite Variable    ${CREATED_BOOKING_ID}    ${CREATED_BOOKING_ID}
    Log To Console    Created Booking ID: ${CREATED_BOOKING_ID}

    Object      response body booking
    String      response body booking firstname                 Sally
    String      response body booking lastname                  Brown
    
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
    Log To Console    First Found Booking ID: ${FIRST_FOUND_BOOKING_ID}

Query Bookings by Firstname and lastname
    [Documentation]    Expect an Array of bookings, each with an Integer bookingid. Filter by firstname and lastname.
    GET         /booking?firstname\=Sally&lastname\=Brown       headers={"Cookie": "token=${TOKEN}"}
    # Output
    Integer     response status                                 200
    Array       response body
    Integer     $[0].bookingid
    Object      $[?(@.bookingid\=\=${CREATED_BOOKING_ID})]

Query Bookings by checkin and checkout dates
    [Documentation]    Expect an Array of bookings, each with an Integer bookingid. Filter by checkin and checkout dates.
    GET         /booking?checkin\=2014-03-13&checkout\=2014-05-21        headers={"Cookie": "token=${TOKEN}", "Accept": "application/json"}
    # Output
    Integer     response status                                 200
    Array       response body
    Object      $[?(@.bookingid\=\=${CREATED_BOOKING_ID})]

Get Created Booking
    [Documentation]    Expect a booking with the created bookingid.
    GET         /booking/${CREATED_BOOKING_ID}        headers={"Cookie": "token=${TOKEN}", "Accept": "application/json"}
    # Output
    Integer     response status                                 200
    Object      response body
    String      response body firstname                 Sally
    String      response body lastname                  Brown
    Integer     response body totalprice                111
    Boolean     response body depositpaid               true
    Object      response body bookingdates
    String      response body bookingdates checkin      2014-03-13
    String      response body bookingdates checkout     2014-05-21
    String      response body additionalneeds           Breakfast

# If creation fails, let us at least try to get the first found booking.
Get First Found Booking
    [Documentation]    Expect a booking with the first found bookingid.
    GET         /booking/${FIRST_FOUND_BOOKING_ID}        headers={"Cookie": "token=${TOKEN}", "Accept": "application/json"}
    # Output
    Integer     response status                                 200
    Object      response body
    String      response body firstname
    String      response body lastname
    Integer     response body totalprice
    Boolean     response body depositpaid
    Object      response body bookingdates
    String      response body bookingdates checkin
    String      response body bookingdates checkout
    String      response body additionalneeds

Update First Found Booking
    [Documentation]    Expect a booking with the first found bookingid to be updated.
    PUT         /booking/${FIRST_FOUND_BOOKING_ID}
    ...         body={"firstname": "John", "lastname": "Doe", "totalprice": 222, "depositpaid": false, "bookingdates": {"checkin": "2024-01-01", "checkout": "2024-01-02"}, "additionalneeds": "Dinner"}
    ...         headers={"Cookie": "token=${TOKEN}", "Content-Type": "application/json", "Accept": "application/json"}

    

    Integer     response status                         200

    Object      response body
    String      response body firstname                 John
    String      response body lastname                  Doe
    Integer     response body totalprice                222
    Boolean     response body depositpaid               false
    Object      response body bookingdates
    String      response body bookingdates checkin      2024-01-01
    String      response body bookingdates checkout     2024-01-02
    String      response body additionalneeds           Dinner

Partial Update First Found Booking
    [Documentation]    Expect a booking with the first found bookingid to be updated partially.
    PATCH         /booking/${FIRST_FOUND_BOOKING_ID}
    ...         body={"additionalneeds": "Twin Beds"}
    ...         headers={"Cookie": "token=${TOKEN}", "Content-Type": "application/json", "Accept": "application/json"}

    Integer     response status                         200

    Object      response body
    String      response body firstname                 John
    String      response body lastname                  Doe
    Integer     response body totalprice                222
    Boolean     response body depositpaid               false
    Object      response body bookingdates
    String      response body bookingdates checkin      2024-01-01
    String      response body bookingdates checkout     2024-01-02
    String      response body additionalneeds           Twin Beds

Delete Created Booking
    [Documentation]    Expect the created booking to be deleted.
    DELETE      /booking/${CREATED_BOOKING_ID}        headers={"Cookie": "token=${TOKEN}", "Accept": "application/json"}

    Integer     response status                         201

    # Verify that the booking is deleted.
    GET         /booking/${CREATED_BOOKING_ID}        headers={"Cookie": "token=${TOKEN}", "Accept": "application/json"}
    Integer     response status                         404