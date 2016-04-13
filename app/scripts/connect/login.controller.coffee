'use strict'

{ TC_JWT }   = require '../../../core/constants.js'
{ login }    = require '../../../core/auth.js'
{ getToken } = require '../../../core/token.js'

ConnectLoginController = (
    $log
    $state
    $stateParams
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

    loginOptions =
      username  : vm.username
      password  : vm.password
      connection: conn
    
    login(loginOptions)
      .then(loginSuccess)
      .catch(loginFailure)

  loginFailure = (error) ->
    vm.error   = true
    vm.loading = false

  loginSuccess = ->
    vm.error   = false
    vm.loading = false

    jwt = localStorage.getItem 'userJWTToken'
    unless jwt
      vm.error = true
    else if vm.retUrl
      Utils.redirectTo Utils.generateReturnUrl(vm.retUrl)
    else
      $state.go 'home'
    
  init = ->
    jwt = getToken(TC_JWT)
    if jwt && vm.retUrl
      Utils.redirectTo Utils.generateReturnUrl(vm.retUrl)
    else if ($stateParams.handle || $stateParams.email) && $stateParams.password
      id = $stateParams.handle || $stateParams.email
      pass = $stateParams.password
      loginOptions =
        username: id
        password: pass
      
      login(loginOptions)
        .then(loginSuccess)
        .catch(loginFailure)
    else
      vm.init = true
    vm

  init()


ConnectLoginController.$inject = [
  '$log'
  '$state'
  '$stateParams'
  'Utils'
  'Constants'
]

angular.module('accounts').controller 'ConnectLoginController', ConnectLoginController
