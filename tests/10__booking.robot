# https://restful-booker.herokuapp.com/apidoc/
# https://github.com/asyrjasalo/RESTinstance
# https://asyrjasalo.github.io/RESTinstance


*** Settings ***
Library         Collections
Library         REST    url=%{ROBOT_API_URL}

Resource       ../resources/auth.resource
Resource       ../resources/booking.resource

Suite Setup     Authenticate and retrieve token


*** Test Cases ***
Create a Booking
    [Documentation]             Expect a booking to be created with a bookingid.
    [Tags]                      create  created

    Create Booking

    [Teardown]                  Delete Created Booking

Get Bookings
    [Documentation]             Expect an Array of bookings, each with an Integer bookingid.
    [Tags]                      get  get_all

    Get All Bookings

Query Bookings by Firstname and lastname
    [Documentation]             Expect an Array of bookings, each with an Integer bookingid. Filter by firstname and lastname.
    [Tags]                      get  query   filter
    [Setup]                     Create Booking

    Find Created Booking By Name

    [Teardown]                  Delete Created Booking

Query Bookings by checkin and checkout dates
    [Documentation]             Expect an Array of bookings, each with an Integer bookingid. Filter by checkin and checkout dates.
    [Tags]                      get  query   filter
    [Setup]                     Create Booking

    Find Created Booking By Dates

    [Teardown]         Delete Created Booking

Get Created Booking
    [Documentation]             Expect a booking with the created bookingid.
    [Tags]                      get  created
    [Setup]                     Create Booking

    Verify Created Booking

    [Teardown]                  Delete Created Booking

# If creation fails, let us at least try to get the first found booking.
Get First Found Booking
    [Documentation]             Expect a booking with the first found bookingid.
    [Tags]                      get  first_found
    [Setup]                     Get All Bookings

    GET                         /booking/${FIRST_FOUND_BOOKING_ID}
    Integer                     response status                         200
    Verify Booking Schema Only  response body

Update First Found Booking
    [Documentation]             Expect a booking with the first found bookingid to be updated.
    [Tags]                      update  first_found
    [Setup]                     Get All Bookings
    PUT                         /booking/${FIRST_FOUND_BOOKING_ID}      body=&{UPDATED_BOOKING}
    Integer                     response status                         200
    Verify Booking Response     response body                           ${UPDATED_BOOKING}

Partial Update First Found Booking
    [Documentation]             Expect a booking with the first found bookingid to be updated partially.
    [Tags]                      patch   first_found
    [Setup]                     Get All Bookings
    
    Partially Update First Found Booking

Delete Created Booking
    [Documentation]             Expect the created booking to be deleted.
    [Tags]                      delete  created
    [Setup]                     Create Booking
    DELETE                      /booking/${CREATED_BOOKING_ID}
    Integer                     response status                         201     # Per Documentation

    GET                         /booking/${CREATED_BOOKING_ID}
    Integer                     response status                         404     # Not Found