# https://github.com/asyrjasalo/RESTinstance
# https://asyrjasalo.github.io/RESTinstance


*** Settings ***
Library         REST    url=%{ROBOT_API_URL}


*** Variables ***
${TOKEN}        None


*** Keywords ***
Authenticate and retrieve token
    [Documentation]    Authenticate with the API and retrieve a token for subsequent requests.
    POST                /auth       body={"username": "%{ROBOT_API_USERNAME}", "password": "%{ROBOT_API_PASSWORD}"}
    ${token_value}=     Output      $.token     also_console=${False}
    Set Suite Variable  ${TOKEN}    ${token_value}
    ${masked_token}=    Evaluate    '*' * len('${token_value}')
    Log                 Token: ${masked_token}  console=True
    Set Headers         {"Cookie": "token=${TOKEN}", "Content-Type": "application/json", "Accept": "application/json"}

