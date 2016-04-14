'use strict'

{ login } = require '../../../core/auth.js'
{ TC_JWT } = require '../../../core/constants.js'

ConnectLoginController = (
    $log
    $rootScope
    $location
    $window
    $state
    $stateParams
    $timeout
    AuthService
    TokenService
    Utils
    Constants) ->
  
  vm           = this
  vm.username  = ''
  vm.password  = ''
  vm.error     = false
  vm.loading   = false
  vm.init      = false
  vm.$stateParams = $stateParams
  vm.retUrl    = decodeURIComponent($stateParams.retUrl)
  
  vm.registrationUrl = 'https://connect.' + Constants.DOMAIN + '/registration'
  vm.forgotPasswordUrl = 'https://connect.' + Constants.DOMAIN + '/forgot-password'

  vm.submit = ->
    vm.error   = false
    vm.loading = true

    # Auth0 connection
    # handle: "LDAP", email: "TC-User-Database"
    conn = if Utils.isEmail(vm.username) then 'TC-User-Database' else 'LDAP'

    options =
      connection: conn
      username: vm.username
      password: vm.password

    login(options).then(loginSuccess, loginFailure)

  loginFailure = (error) ->
    $scope.$apply ->
      vm.error   = true
      vm.loading = false

  loginSuccess = ->
    jwt = localStorage.getItem(TC_JWT)

    unless jwt
      vm.error = true
    else if vm.retUrl
      redirectUrl = Utils.generateReturnUrl vm.retUrl
      $log.info 'redirect back to ' + redirectUrl
      $window.location = redirectUrl
    else
      $state.go 'home'
  
  # vm.socialLogin = (provider) ->
  #   callbackUrl = $state.href 'home', {}, { absolute: true }
  #   authUrl = AuthService.generateSSOUrl provider, callbackUrl
  #   $log.info "auth with: "+authUrl
  #   $window.location = authUrl
  
  init = ->
    jwt = localStorage.getItem(TC_JWT)

    if jwt && vm.retUrl
      redirectUrl = Utils.generateReturnUrl vm.retUrl
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


ConnectLoginController.$inject = [
  '$log'
  '$rootScope'
  '$location'
  '$window'
  '$state'
  '$stateParams'
  '$timeout'
  'AuthService'
  'TokenService'
  'Utils'
  'Constants'
]

angular.module('accounts').controller 'ConnectLoginController', ConnectLoginController
