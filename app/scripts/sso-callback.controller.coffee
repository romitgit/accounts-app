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
  vm.error = null
  
  vm.hasError = ->
    !!vm.error
  
  init = ->
    status = $stateParams.status
    if status && status > 200 
      $log.debug 'status:'+$stateParams.status
      $log.debug 'message:'+$stateParams.message
      if status >= 500
        $log.error status + ', ' + $stateParams.message
        vm.error = 'Unexpected error occurred.'
      else if status >= 400
        vm.error = $stateParams.message
      else
        $log.warn status + ', ' + $stateParams.message
      return vm
  
    TokenService.setAppirioJWT $stateParams.userJWTToken
    TokenService.getAuth0Token $stateParams.tcjwt || ''
    TokenService.setSSOToken $stateParams.tcsso || ''
    
    redirectUrl = Utils.generateReturnUrl $stateParams.retUrl
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
