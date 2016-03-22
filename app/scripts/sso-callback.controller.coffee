'use strict'

SSOCallbackController = (
  $log
  $state
  $window
  $cookies
  $http
  API_URL
  TokenService
  AuthService
  Utils) ->
  
  vm = this

  authenticate = (token, refreshToken) ->
    TokenService.setAuth0Token token
    TokenService.setAuth0RefreshToken refreshToken

    success = (jwt) ->
      TokenService.setAppirioJWT jwt
      TokenService.setSSOToken $cookies.get('tcsso') || ''
      redirectUrl = Utils.generateReturnUrl vm.state
      $log.info 'redirect back to ' + redirectUrl
      $window.location = redirectUrl

    AuthService.getNewJWT()
      .then(success)
  
  init = ->
    params = Utils.parseQuery $window.location.hash.substring(1)
    token        = params.id_token
    refreshToken = params.refresh_token
    # TODO: need to check state
    vm.state     = params.state
    $log.debug 'Auth0: token: '+token
    $log.debug 'Auth0: refreshToken: '+refreshToken
    $log.debug 'Auth0: state: '+vm.state

    authenticate(token, refreshToken)
    vm
  
  init()

SSOCallbackController.$inject = [
  '$log'
  '$state'
  '$window'
  '$cookies'
  '$http'
  'API_URL'
  'TokenService'
  'AuthService'
  'Utils'
]

angular.module('accounts').controller 'SSOCallbackController', SSOCallbackController
