'use strict'

SSOCallbackController = (
  $log
  $state
  $window
  $cookies
  $http
  API_URL
  TokenService
  Utils) ->
  
  vm = this

  authenticate = (token, refreshToken) ->
    params =
      param:
        externalToken: token
        refreshToken : refreshToken

    config =
      method: 'POST'
      url: "#{API_URL}/v3/authorizations"
      withCredentials: true,
      data: params

    success = (res) ->
      TokenService.setAppirioJWT res.data?.result?.content?.token
      TokenService.setSSOToken $cookies.get('tcsso') || ''
      redirectUrl = Utils.generateReturnUrl vm.state
      $log.info 'redirect back to ' + redirectUrl
      $window.location = redirectUrl

    $http(config).then (success)
  
  init = ->
    params = Utils.parseQuery $window.location.hash.substring(1)
    token        = params.id_token
    refreshToken = params.refresh_token
    # TODO: need to check state
    vm.state     = params.state
    $log.debug 'Auth0: token: '+token
    $log.debug 'Auth0: refreshToken: '+refreshToken
    $log.debug 'Auth0: state: '+vm.state

    TokenService.setAuth0Token token
    TokenService.setAuth0RefreshToken refreshToken

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
  'Utils'
]

angular.module('accounts').controller 'SSOCallbackController', SSOCallbackController
