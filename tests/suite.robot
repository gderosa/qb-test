*** Settings ***
Library         REST    url=https://restful-booker.herokuapp.com/    loglevel=INFO

*** Variables ***
${USERNAME}       admin
${PASSWORD}       password123
${TOKEN}          None

*** Test Cases ***
Authenticate
    [Documentation]    Authenticate and retrieve a token
    POST    /auth    body={\"username\": \"${USERNAME}\", \"password\": \"${PASSWORD}\"}
    Output
   