'use strict'

LoginController = (
    $log
    $rootScope
    $location
    $window
    $state
    $stateParams
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

    # TODO 
    tcjwt = 'DUMMY-TCJWT'
    tcsso = 'DUMMY-TCSSO'
    jwt = TokenService.getAppirioJWT()
    unless jwt
      vm.error = true
    else if $stateParams.retUrl
      redirectUrl = $stateParams.retUrl + '?jwt=' + encodeURIComponent(jwt) + '&tcjwt=' + encodeURIComponent(tcjwt) + '&tcsso=' + encodeURIComponent(tcsso)
      $log.info 'redirect back to ' + redirectUrl
      $window.location = redirectUrl
    else
        $state.go 'home'

  init = ->
    jwt = TokenService.getAppirioJWT()
    if jwt && $stateParams.retUrl
      redirectUrl = $stateParams.retUrl + '?jwt=' + encodeURIComponent(jwt)
      $log.info 'redirect back to ' + redirectUrl
      $window.location = redirectUrl
    else if ($stateParams.handle || $stateParams.email) && $stateParams.password
      id = $stateParams.handle || $stateParams.email
      pass = $stateParams.password
      loginOptions =
        username: id
        password: pass
        error   : loginFailure
        success : loginSuccess
      AuthService.login loginOptions
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
  '$stateParams'
  '$timeout'
  'AuthService'
  'TokenService'
]

angular.module('accounts').controller 'LoginController', LoginController
