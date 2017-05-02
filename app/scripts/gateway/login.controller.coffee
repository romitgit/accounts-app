'use strict'
fetch = require 'isomorphic-fetch'
{ DOMAIN, API_GATEWAY_AUTH_ENDPOINT } = require '../../../core/constants.js'
{ login, socialLogin, getFreshToken } = require '../../../core/auth.js'
{ isEmail, setupLoginEventMetrics } = require '../../../core/utils.js'
{ redirectTo, generateZendeskReturnUrl, generateReturnUrl } = require '../../../core/url.js'

TCGatewayLoginController = (
  $log
  $scope
  $window
  $state
  $stateParams
  UserService
  $http
) ->

  vm = this
  vm.loading   = false
  vm.init      = false

  vm.baseUrl = "https://www.#{DOMAIN}"
  vm.registrationUrl   = $state.href('MEMBER_REGISTRATION', { activated: true })
  vm.forgotPasswordUrl = $state.href('MEMBER_FORGOT_PASSWORD', { absolute: true })
  vm.confirmActivationUrl = $state.href('MEMBER_REGISTRATION_SUCCESS', { absolute: true })
  vm.retUrl = if $stateParams.retUrl then decodeURIComponent($stateParams.retUrl) else vm.baseUrl

  vm.$stateParams = $stateParams
  vm.loginErrors =
    USERNAME_NONEXISTANT: false
    WRONG_PASSWORD: false
    SOCIAL_LOGIN_ERROR: false

  vm.socialLogin = (provider) ->
    # loading
    vm.loading = true
    # clear error flags
    vm.loginErrors.USERNAME_NONEXISTANT = false
    vm.loginErrors.WRONG_PASSWORD = false
    vm.loginErrors.SOCIAL_LOGIN_ERROR = false

    loginOptions =
      popup     : true
      connection: provider

    socialLogin(loginOptions)
      .then(loginSuccess)
      .catch(loginFailure)

  vm.login = ->
    # loading
    vm.loading = true
    # clear error flags
    vm.loginErrors.USERNAME_NONEXISTANT = false
    vm.loginErrors.WRONG_PASSWORD = false
    vm.loginErrors.SOCIAL_LOGIN_ERROR = false

    validateUsername(vm.username)
      .then (result) ->
        # if username/email is available for registration, it means it is a non existant user
        if result
          vm.loginErrors.USERNAME_NONEXISTANT = true
          vm.loading = false
        else
          doLogin(vm.username, vm.currentPassword)
      .catch (err) ->
        vm.loginErrors.USERNAME_NONEXISTANT = false
        doLogin(vm.username, vm.currentPassword)

  validateUsername = (username) ->
    validator = if isEmail(username) then UserService.validateEmail else UserService.validateHandle
    validator username
      .then (res) ->
        res?.valid

  doLogin = (username, password) ->
    loginOptions =
      username  : username
      password  : password

    login(loginOptions)
      .then(loginSuccess)
      .catch(loginFailure)

  loginFailure = (error) ->
    $log.warn(error)
    vm.loading = false

    if error?.message?.toLowerCase() == 'account inactive'
      # redirect to the page to prompt activation
      $log.info 'redirect to #{vm.confirmActivationUrl}'
      $window.location = vm.confirmActivationUrl
    else if error?.message?.toLowerCase() == 'user is not registered'
      vm.loginErrors.SOCIAL_LOGIN_ERROR = true
      $scope.$apply() # refreshing the screen
    else
      vm.loginErrors.WRONG_PASSWORD = true
      vm.password = ''

  redirectToGateway = (params, jwt) ->
    body = {
      client_id: params.client_id,
      state: params.state || '',
      redirect_uri: params.redirect_uri,
      scope: params.scope,
      response_type: params.response_type,
      user_id: 123
    }
    options = {
      url: API_GATEWAY_AUTH_ENDPOINT,
      data: body,
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    }

    respHandler = (resp) ->
      $window.location.href = resp.data.redirect_uri + '?code=' + resp.data.code

    $http(options).then(respHandler)

  loginSuccess = ->
    vm.loading = false

    # setup login event for analytics tracking
    setupLoginEventMetrics(vm.username)
    # TODO add consent form
    redirect = (jwt) ->
      redirectToGateway($stateParam, jwt)
    getFreshToken().then( redirect )

  init = ->
    { handle, email, password } = $stateParams

    getJwtSuccess = (jwt) ->
      if jwt && vm.retUrl
        redirectToGateway($stateParams, jwt)
      else if (handle || email) && password
        doLogin(handle || email, password)

    # "return_to" is handed by Zendesk.
    # It's in the case of sign-in or session is expired in Zendesk. It always needs to log in.
    if $stateParams.return_to
      vm
    else
      getFreshToken().then(getJwtSuccess)
    vm

  init()


TCGatewayLoginController.$inject = [
  '$log'
  '$scope'
  '$window'
  '$state'
  '$stateParams'
  'UserService'
  '$http'
]

angular.module('accounts').controller 'TCGatewayLoginController', TCGatewayLoginController
