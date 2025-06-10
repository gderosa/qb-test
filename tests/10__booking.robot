# https://restful-booker.herokuapp.com/apidoc/
# https://github.com/asyrjasalo/RESTinstance
# https://asyrjasalo.github.io/RESTinstance


*** Settings ***
Library         REST    url=%{ROBOT_API_URL}

Suite Setup     Authenticate and retrieve token


*** Variables ***
${TOKEN}                    None
${CREATED_BOOKING_ID}       None
${FIRST_FOUND_BOOKING_ID}   None
&{CREATED_BOOKINGDATES}     checkin=2014-03-13      checkout=2014-05-21
&{UPDATED_BOOKINGDATES}     checkin=2024-01-01      checkout=2024-01-02
&{CREATED_BOOKING}
...                         firstname=Sally         lastname=Brown
...                         totalprice=111
...                         depositpaid=${True}
...                         bookingdates=&{CREATED_BOOKINGDATES}
...                         additionalneeds=Breakfast
&{UPDATED_BOOKING}
...                         firstname=John          lastname=Doe
...                         totalprice=222
...                         depositpaid=${False}
...                         bookingdates=&{UPDATED_BOOKINGDATES}
...                         additionalneeds=Dinner

*** Keywords ***
Authenticate and retrieve token
    [Documentation]    Authenticate with the API and retrieve a token for subsequent requests.
    POST                /auth       body={"username": "%{ROBOT_API_USERNAME}", "password": "%{ROBOT_API_PASSWORD}"}
    ${token_value}=     Output      $.token     also_console=${False}
    Set Suite Variable  ${TOKEN}    ${token_value}
    ${masked_token}=    Evaluate    '*' * len('${token_value}')
    Log                 Token: ${masked_token}  console=True
    Set Headers         {"Cookie": "token=${TOKEN}", "Content-Type": "application/json", "Accept": "application/json"}


*** Test Cases ***
Create a Booking
    [Documentation]     Expect a booking to be created with a bookingid.
    [Tags]              create  created

    POST    /booking    body=&{CREATED_BOOKING}

    Integer     response status                                 200                     201

    Integer     response body bookingid
    ${CREATED_BOOKING_ID}=      Output                          $.bookingid
    Set Suite Variable          ${CREATED_BOOKING_ID}           ${CREATED_BOOKING_ID}
    Log To Console              Created Booking ID: ${CREATED_BOOKING_ID}

    Object      response body booking
    String      response body booking firstname                 ${CREATED_BOOKING.firstname}
    String      response body booking lastname                  ${CREATED_BOOKING.lastname}
    Integer     response body booking totalprice                ${CREATED_BOOKING.totalprice}
    Boolean     response body booking depositpaid               ${CREATED_BOOKING.depositpaid}
    Object      response body booking bookingdates
    String      response body booking bookingdates checkin      ${CREATED_BOOKING.bookingdates.checkin}
    String      response body booking bookingdates checkout     ${CREATED_BOOKING.bookingdates.checkout}
    String      response body booking additionalneeds           ${CREATED_BOOKING.additionalneeds}

Get Bookings
    [Documentation]    Expect an Array of bookings, each with an Integer bookingid.
    [Tags]             get  get_all

    GET         /booking
    Integer     response status                                 200
    Array       response body
    Integer     $[0].bookingid
    ${FIRST_FOUND_BOOKING_ID}=    Output    $[0].bookingid
    Set Suite Variable    ${FIRST_FOUND_BOOKING_ID}    ${FIRST_FOUND_BOOKING_ID}
    Log To Console    First Found Booking ID: ${FIRST_FOUND_BOOKING_ID}

Query Bookings by Firstname and lastname
    [Documentation]    Expect an Array of bookings, each with an Integer bookingid. Filter by firstname and lastname.
    [Tags]             get  query   filter

    GET         /booking?firstname\=${CREATED_BOOKING.firstname}&lastname\=${CREATED_BOOKING.lastname}
    # Output
    Integer     response status                                 200
    Array       response body
    Integer     $[0].bookingid
    Object      $[?(@.bookingid\=\=${CREATED_BOOKING_ID})]

Query Bookings by checkin and checkout dates
    [Documentation]    Expect an Array of bookings, each with an Integer bookingid. Filter by checkin and checkout dates.
    [Tags]             get  query   filter

    GET         /booking?checkin\=${CREATED_BOOKINGDATES.checkin}&checkout\=${CREATED_BOOKINGDATES.checkout}
    # Output
    Integer     response status                                 200
    Array       response body
    Object      $[?(@.bookingid\=\=${CREATED_BOOKING_ID})]

Get Created Booking
    [Documentation]    Expect a booking with the created bookingid.
    [Tags]             get  created

    GET         /booking/${CREATED_BOOKING_ID}
    # Output
    Integer     response status                         200
    Object      response body
    String      response body firstname                 ${CREATED_BOOKING.firstname}
    String      response body lastname                  ${CREATED_BOOKING.lastname}
    Integer     response body totalprice                ${CREATED_BOOKING.totalprice}
    Boolean     response body depositpaid               ${CREATED_BOOKING.depositpaid}
    Object      response body bookingdates
    String      response body bookingdates checkin      ${CREATED_BOOKING.bookingdates.checkin}
    String      response body bookingdates checkout     ${CREATED_BOOKING.bookingdates.checkout}
    String      response body additionalneeds           ${CREATED_BOOKING.additionalneeds}

# If creation fails, let us at least try to get the first found booking.
Get First Found Booking
    [Documentation]    Expect a booking with the first found bookingid.
    [Tags]             get  first_found

    GET         /booking/${FIRST_FOUND_BOOKING_ID}
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
    [Tags]             update  first_found

    PUT         /booking/${FIRST_FOUND_BOOKING_ID}      body=&{UPDATED_BOOKING}

    Integer     response status                         200

    Object      response body
    String      response body firstname                 ${UPDATED_BOOKING.firstname}
    String      response body lastname                  ${UPDATED_BOOKING.lastname}
    Integer     response body totalprice                ${UPDATED_BOOKING.totalprice}
    Boolean     response body depositpaid               ${UPDATED_BOOKING.depositpaid}
    Object      response body bookingdates
    String      response body bookingdates checkin      ${UPDATED_BOOKING.bookingdates.checkin}
    String      response body bookingdates checkout     ${UPDATED_BOOKING.bookingdates.checkout}
    String      response body additionalneeds           ${UPDATED_BOOKING.additionalneeds}

Partial Update First Found Booking
    [Documentation]    Expect a booking with the first found bookingid to be updated partially.
    [Tags]             patch  first_found

    PATCH         /booking/${FIRST_FOUND_BOOKING_ID}    body={"additionalneeds": "Twin Beds"}

    Integer     response status                         200

    Object      response body
    String      response body firstname                 ${UPDATED_BOOKING.firstname}
    String      response body lastname                  ${UPDATED_BOOKING.lastname}
    Integer     response body totalprice                ${UPDATED_BOOKING.totalprice}
    Boolean     response body depositpaid               ${UPDATED_BOOKING.depositpaid}
    Object      response body bookingdates
    String      response body bookingdates checkin      ${UPDATED_BOOKING.bookingdates.checkin}
    String      response body bookingdates checkout     ${UPDATED_BOOKING.bookingdates.checkout}
    String      response body additionalneeds           Twin Beds

Delete Created Booking
    [Documentation]    Expect the created booking to be deleted.
    [Tags]             delete  created

    DELETE      /booking/${CREATED_BOOKING_ID}

    Integer     response status                         201

    # Verify that the booking is deleted.
    GET         /booking/${CREATED_BOOKING_ID}
    Integer     response status                         404