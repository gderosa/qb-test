# https://restful-booker.herokuapp.com/apidoc/
# https://github.com/asyrjasalo/RESTinstance
# https://asyrjasalo.github.io/RESTinstance

CREATED_BOOKINGDATES = dict(checkin='2014-03-13', checkout='2014-05-21')
UPDATED_BOOKINGDATES = dict(checkin='2024-01-01', checkout='2024-01-02')

CREATED_BOOKING = dict(
    firstname='Sally', lastname='Brown',
    totalprice=111,
    depositpaid=True,
    bookingdates=CREATED_BOOKINGDATES,
    additionalneeds='Breakfast'
)
UPDATED_BOOKING = dict(
    firstname='John', lastname='Doe',
    totalprice=222,
    depositpaid=False,
    bookingdates=UPDATED_BOOKINGDATES,
    additionalneeds='Dinner'
)
