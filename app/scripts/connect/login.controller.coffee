'use strict'

{ getFreshToken, login }    = require '../../../core/auth.js'
{ getV3Jwt,  redirectToAuth0} = require '../../../core/auth.js'
{ getLoginConnection, isEmail } = require '../../../core/utils.js'
{ generateReturnUrl, redirectTo, getBaseUrl } = require '../../../core/url.js'

ConnectLoginController = (
  $scope
  $log
  $state
  $stateParams
  UserService
) ->
  vm           = this

  # We have to send the user to Auth0
  redirectToAuth0($stateParams)

  vm.username  = ''
  vm.password  = ''
  vm.error     = false
  vm.loading   = false
  vm.initialized  = false
  vm.$stateParams = $stateParams
  vm.passwordReset = vm.$stateParams.passwordReset == true
  vm.loginErrors =
    USERNAME_NONEXISTANT: false
    WRONG_PASSWORD: false
    ACCOUNT_INACTIVE: false
  
  vm.baseUrl = getBaseUrl()
  vm.registrationUrl   = $state.href('CONNECT_REGISTRATION', { activated: true }, { absolute: true })
  vm.forgotPasswordUrl = $state.href('CONNECT_FORGOT_PASSWORD', {}, { absolute: true })
  vm.retUrl = if $stateParams.retUrl then decodeURIComponent($stateParams.retUrl) else vm.baseUrl

  vm.hasPasswordError = ->
    vm.loginErrors.WRONG_PASSWORD

  vm.submit = ->
    vm.loading = true
    # clear error flags
    vm.loginErrors.USERNAME_NONEXISTANT = false
    vm.loginErrors.WRONG_PASSWORD = false
    vm.loginErrors.ACCOUNT_INACTIVE = false
    if vm.username == ''
      vm.loginErrors.USERNAME_NONEXISTANT = true
      vm.loading = false
    else
      validateUsername(vm.username)
        .then (result) ->
          # if username/email is available for registration, it means it is a non existant user
          if result
            vm.loginErrors.USERNAME_NONEXISTANT = true
            vm.loading = false
          else
            callLogin(vm.username, vm.password)
        .catch (err) ->
          vm.loginErrors.USERNAME_NONEXISTANT = false
          callLogin(vm.username, vm.password)

  loginFailure = (error) ->
    if error?.message?.toLowerCase() == 'account inactive'
      # redirect to the page to prompt activation 
      vm.loginErrors.ACCOUNT_INACTIVE = true
    else
      vm.loginErrors.WRONG_PASSWORD = true
    $scope.$apply ->
      vm.error   = true
      vm.loading = false

  loginSuccess = ->
    jwt = getV3Jwt()

    unless jwt
      vm.error = true
    else if vm.retUrl
      redirectTo generateReturnUrl(vm.retUrl)
    else
      $state.go 'home'

  callLogin = (id, password) ->
    options =
      username: id
      password: password

    login(options).then(loginSuccess, loginFailure)

  
  validateUsername = (username) ->
    validator = if isEmail(username) then UserService.validateEmail else UserService.validateHandle
    validator username
      .then (res) ->
        res?.valid || res.reasonCode != 'ALREADY_TAKEN'

  init = ->
    { handle, email, password } = $stateParams
    vm.initialized = true
    getJwtSuccess = (jwt) ->
      if jwt && vm.retUrl
        redirectTo generateReturnUrl(vm.retUrl)
      else if (handle || email) && password
        callLogin(handle || email, password)

    getFreshToken().then(getJwtSuccess).catch(() => {
      # ignore, to stop angular complaining about unhandled promise
    })

    vm

  init()


ConnectLoginController.$inject = [
  '$scope'
  '$log'
  '$state'
  '$stateParams'
  'UserService'
]

angular.module('accounts').controller 'ConnectLoginController', ConnectLoginController
