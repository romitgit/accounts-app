'use strict'

LoginController = (
    $log
    $rootScope
    $location
    $window
    $state
    $timeout
    AuthService
    TokenService) ->
  
  vm           = this
  vm.username  = ''
  vm.password  = ''
  vm.error     = false
  vm.loading   = false
  vm.init      = false

  vm.submit = ->
    vm.error   = false
    vm.loading = true

    loginOptions =
      username: vm.username
      password: vm.password
      error   : loginFailure
      success : loginSuccess

    AuthService.login loginOptions

  loginFailure = (error) ->
    vm.error   = true
    vm.loading = false

  loginSuccess = ->
    vm.error   = false
    vm.loading = false

    jwt = TokenService.getAppirioJWT()
    unless jwt
      vm.error = true

    else if $location.search().retUrl
      redirectUrl = $location.search().retUrl + '?jwt=' + encodeURIComponent(jwt)
      $log.info 'redirect back to ' + redirectUrl
      $window.location = redirectUrl
    
    else
        $state.go 'home'

  init = ->
    jwt = TokenService.getAppirioJWT()
    if jwt && $location.search().retUrl
      redirectUrl = $location.search().retUrl + '?jwt=' + encodeURIComponent(jwt)
      $log.info 'redirect back to ' + redirectUrl
      $window.location = redirectUrl
    else
      vm.init = true
    vm

  init()


LoginController.$inject = [
  '$log'
  '$rootScope'
  '$location'
  '$window'
  '$state'
  '$timeout'
  'AuthService'
  'TokenService'
]

angular.module('accounts').controller 'LoginController', LoginController
