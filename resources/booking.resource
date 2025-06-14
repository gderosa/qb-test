# https://restful-booker.herokuapp.com/apidoc/
# https://github.com/asyrjasalo/RESTinstance
# https://asyrjasalo.github.io/RESTinstance


*** Settings ***
Library         Collections
Library         REST    url=%{ROBOT_API_URL}


*** Variables ***
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
Verify Booking Response
    [Arguments]     ${booking}                          ${expected}
    Object          ${booking}
    String          ${booking} firstname                ${expected.firstname}
    String          ${booking} lastname                 ${expected.lastname}
    Integer         ${booking} totalprice               ${expected.totalprice}
    Boolean         ${booking} depositpaid              ${expected.depositpaid}
    Object          ${booking} bookingdates
    String          ${booking} bookingdates checkin     ${expected.bookingdates.checkin}
    String          ${booking} bookingdates checkout    ${expected.bookingdates.checkout}
    String          ${booking} additionalneeds          ${expected.additionalneeds}

Verify Booking Schema Only
    [Arguments]     ${booking}
    Object          ${booking}
    String          ${booking} firstname
    String          ${booking} lastname
    Integer         ${booking} totalprice
    Boolean         ${booking} depositpaid
    Object          ${booking} bookingdates
    String          ${booking} bookingdates checkin
    String          ${booking} bookingdates checkout
    String          ${booking} additionalneeds

Create Booking
    [Documentation]    Create a booking with the given details.
    [Arguments]

    POST                        /booking                                body=&{CREATED_BOOKING}
    Integer                     response status                         200     201
    Integer                     response body bookingid
    ${bookingid}=               Output                                  $.bookingid
    Set Test Variable           ${CREATED_BOOKING_ID}                   ${bookingid}
    Verify Booking Response     response body booking                   ${CREATED_BOOKING}

Verify Created Booking
    [Documentation]             Verify that the created booking matches the expected details.
    [Arguments]

    GET                         /booking/${CREATED_BOOKING_ID}
    Integer                     response status                         200
    Verify Booking Response     response body                           ${CREATED_BOOKING}

Find Created Booking By Name
    [Documentation]             Find a booking by firstname and lastname.
    GET                 /booking?firstname\=${CREATED_BOOKING.firstname}&lastname\=${CREATED_BOOKING.lastname}
    Integer             response status                                 200
    Array               response body
    Integer             $[0].bookingid
    Object              $[?(@.bookingid\=\=${CREATED_BOOKING_ID})]

Find Created Booking By Dates
    [Documentation]             Find a booking by checkin and checkout dates.
    GET                 /booking?checkin\=${CREATED_BOOKINGDATES.checkin}&checkout\=${CREATED_BOOKINGDATES.checkout}
    Integer             response status                                 200
    Array               response body
    Object              $[?(@.bookingid\=\=${CREATED_BOOKING_ID})]

Delete Created Booking
    [Documentation]             Delete a booking with the given bookingid.
    [Arguments]

    DELETE                      /booking/${CREATED_BOOKING_ID}
    Integer                     response status                         201     # Per Documentation

    GET                         /booking/${CREATED_BOOKING_ID}
    Integer                     response status                         404     # Not Found

Get All Bookings
    [Documentation]             Retrieve all bookings.
    GET                         /booking
    Integer                     response status                         200
    Array                       response body
    Integer                     $[0].bookingid
    ${FIRST_FOUND_BOOKING_ID}=    Output                                $[0].bookingid
    Set Test Variable           ${FIRST_FOUND_BOOKING_ID}               ${FIRST_FOUND_BOOKING_ID}
    Log                         First Found Booking ID: ${FIRST_FOUND_BOOKING_ID}   console=True

Partially Update First Found Booking
    &{changes}=                 Create Dictionary                       additionalneeds=Twin Beds
    &{PARTIALLY_UPDATED_BOOKING}=   Copy Dictionary                     ${UPDATED_BOOKING}
    Set To Dictionary           ${PARTIALLY_UPDATED_BOOKING}            &{changes}

    PATCH                       /booking/${FIRST_FOUND_BOOKING_ID}      body=${changes}
    Integer                     response status                         200
    Verify Booking Response     response body                           ${PARTIALLY_UPDATED_BOOKING}
