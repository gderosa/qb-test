# https://github.com/asyrjasalo/RESTinstance
# https://asyrjasalo.github.io/RESTinstance

*** Settings ***
Library         REST    url=https://restful-booker.herokuapp.com/

*** Test Cases ***
Health Check
    [Documentation]     Expect a 201 response from the server
    ...                 https://restful-booker.herokuapp.com/apidoc/index.html#api-Ping-Ping
    GET         /ping
    Integer     response status     201
