'use strict'

SSOCallbackController = (
  $log
  $state
  $stateParams
  $window
  $cookies
  $http
  API_URL
  TokenService
  AuthService
  Utils) ->
  
  vm = this
  vm.retUrl = encodeURIComponent($stateParams.retUrl)
  vm.$stateParams = $stateParams
  vm.error = null
  
  vm.hasError = ->
    !!vm.error
  
  init = ->
    status = $stateParams.status
    message = decodeURIComponent($stateParams.message)
    if status && status > 200 
      $log.debug 'status:'+status
      $log.debug 'message:'+message
      if status >= 500
        $log.error status + ', ' + message
        vm.error = 'Unexpected error occurred.'
      else if status >= 400
        vm.error = message
      else
        $log.warn status + ', ' + message
      return vm
  
    TokenService.setAppirioJWT $stateParams.userJWTToken
    TokenService.getAuth0Token $stateParams.tcjwt || ''
    TokenService.setSSOToken $stateParams.tcsso || ''
    
    redirectUrl = Utils.generateReturnUrl $stateParams.retUrl
    unless redirectUrl
      vm.error = 'Invalid URL is assigned to the return-URL.'
    else
      $log.info 'redirect back to ' + redirectUrl
      $window.location = redirectUrl
    vm
  
  init()

SSOCallbackController.$inject = [
  '$log'
  '$state'
  '$stateParams'
  '$window'
  '$cookies'
  '$http'
  'API_URL'
  'TokenService'
  'AuthService'
  'Utils'
]

angular.module('accounts').controller 'SSOCallbackController', SSOCallbackController
