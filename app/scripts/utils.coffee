'use strict'

Utils = (
  $log
  API_URL
  AUTH0_DOMAIN
  AUTH0_CLIENT_ID
  TokenService
  ) ->

  # returns true if the value is email address  
  isEmail = (value) ->
    EMAIL_PATTERN = /^(([^<>()[\]\.,:\s@\"]+(\.[^<>()[\]\.,:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,:\s@\"]+\.)+[^<>()[\]\.,:\s@\"]{2,})$/i
    EMAIL_PATTERN.test value

  # parseQuery("p1=v1&p2=p3&p4")
  # returns {p1:v1, p2:v2, p3:null}
  parseQuery = (query) ->
    params = {}
    parseKV = (kv) ->
      pair = kv.split '='
      if pair.length == 1
        params[pair[0]] = null
      else
        params[pair[0]] = decodeURIComponent(pair[1])

    parseKV kv for kv in query.split '&'
    params

  # generate URL to Auth0 authentication endpoint with parameters.
  # https://auth0.com/docs/protocols#oauth-for-native-clients-and-javascript-in-the-browser
  generateSSOUrl = (org, callbackUrl, state) ->
    apiUrl = API_URL.replace 'api-work', 'api'
    [
      "https://#{AUTH0_DOMAIN}/authorize?"
      "response_type=token"
      "&client_id=#{AUTH0_CLIENT_ID}"
      "&connection=#{org}"
      "&redirect_uri=#{encodeURIComponent(callbackUrl)}"
      "&state=#{encodeURIComponent(state)}"
      "&scope=openid%20profile%20offline_access"
      "&device=browser"
    ].join('')
    
  # generate URL to return application with tokens.
  # The url is generated with values from:
  # - TokenService.getAppirioJWT()
  # - TokenService.getAuth0Token()
  # - TokenService.getSSOToken()
  # format:
  #   returnUrlBase?jwt={V3_JWT}&tcjwt={V2_JWT}&tcsso={V2_SSO_TOKEN}
  generateReturnUrl = (returnUrlBase) ->
    v3jwt = TokenService.getAppirioJWT()
    unless v3jwt
      $log.error 'JWT is not found in the storage.'
    v2jwt = TokenService.getAuth0Token() || ''
    v2sso = TokenService.getSSOToken() || ''
    returnUrlBase + '?jwt=' + encodeURIComponent(v3jwt) + '&tcjwt=' + encodeURIComponent(v2jwt) + '&tcsso=' + encodeURIComponent(v2sso)

  # expose functions
  isEmail           : isEmail
  parseQuery        : parseQuery
  generateSSOUrl    : generateSSOUrl
  generateReturnUrl : generateReturnUrl

Utils.$inject = [
  '$log'
  'API_URL'
  'AUTH0_DOMAIN'
  'AUTH0_CLIENT_ID'
  'TokenService'
]

angular.module('accounts').factory 'Utils', Utils
  
