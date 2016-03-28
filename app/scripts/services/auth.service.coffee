'use strict'

replace = require 'lodash/replace'

AuthService = (
  $log
  $q
  $cookies
  $http
  API_URL
  auth0
  TokenService
) ->

  API_URL = API_URL.replace 'api-work','api'

  auth0Signin = (options) ->

    $log.info "*** config ***"
    $log.info auth0.config
    
    params =
      #client_id     : AUTH0_CLIENT_ID
      scope         : 'openid profile offline_access'
      #response_type : 'token'
      connection    : 'LDAP'
      #device        : 'Browser'

    angular.extend params, options
    $log.info "*** params ***"
    $log.info params
    
    d = $q.defer()
    auth0.signin(
      options
      (profile, id_token, access_token, state, refresh_token) ->
        res =
          profile : profile
          idToken : id_token
          accessToken : access_token
          state : state
          refreshToken : refresh_token
        $log.info '*** res ***'
        $log.info res
        d.resolve res
      (error) ->
        d.reject error
      'Auth0'
    )
    d.promise

  setAuth0Tokens = (res) ->
    TokenService.setAuth0Token res?.idToken
    TokenService.setAuth0RefreshToken res?.refreshToken

  getNewJWT = ->
    params =
      param:
        refreshToken: TokenService.getAuth0RefreshToken()
        externalToken: TokenService.getAuth0Token()

    config =
      method: 'POST'
      url: "#{API_URL}/v3/authorizations"
      #url: "http://localhost:8080/v3/authorizations"
      withCredentials: true,
      data: params

    success = (res) ->
      res.data?.result?.content?.token

    $http(config).then (success)

  setJWT = (JWT) ->
    TokenService.setAppirioJWT JWT

  setSSOToken = ->
    tcsso = $cookies.get('tcsso') || ''
    TokenService.setSSOToken tcsso

  login = (options) ->
    success = options.success || angular.noop
    error = options.error || angular.noop

    auth0Signin(options)
      .then(setAuth0Tokens)
      .then(getNewJWT)
      .then(setJWT)
      .then(setSSOToken)
      .then(success)
      .catch(error)

  # expose
  login : login

AuthService.$inject = [
  '$log'
  '$q'
  '$cookies'
  '$http'
  'API_URL'
  'auth'
  'TokenService'
]

angular.module('accounts').factory '$authService', AuthService
