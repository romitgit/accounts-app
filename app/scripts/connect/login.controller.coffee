'use strict'

{ DOMAIN }   = require '../../../core/constants.js'
{ getFreshToken, login }    = require '../../../core/auth.js'
{ getV3Jwt } = require '../../../core/auth.js'
{ getLoginConnection } = require '../../../core/utils.js'
{ generateReturnUrl, redirectTo } = require '../../../core/url.js'

ConnectLoginController = (
  $scope
  $state
  $stateParams
) ->
  vm           = this
  vm.username  = ''
  vm.password  = ''
  vm.error     = false
  vm.loading   = false
  vm.init      = false
  vm.$stateParams = $stateParams
  vm.passwordReset = vm.$stateParams.passwordReset == true
  
  vm.baseUrl = "https://connect.#{DOMAIN}"
  vm.registrationUrl   = $state.href('CONNECT_REGISTRATION', { activated: true }, { absolute: true })
  vm.forgotPasswordUrl = $state.href('CONNECT_FORGOT_PASSWORD', { absolute: true })
  vm.retUrl = if $stateParams.retUrl then decodeURIComponent($stateParams.retUrl) else vm.baseUrl  

  vm.submit = ->
    callLogin(vm.username, vm.password)

  loginFailure = (error) ->
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
    vm.error   = false
    vm.loading = true

    options =
      username: id
      password: password
    
    login(options).then(loginSuccess, loginFailure)

  init = ->
    { handle, email, password } = $stateParams

    getJwtSuccess = (jwt) ->
      if jwt && vm.retUrl
        redirectTo generateReturnUrl(vm.retUrl)
      else if (handle || email) && password
        callLogin(handle || email, password)

    getFreshToken().then(getJwtSuccess)

    vm

  init()


ConnectLoginController.$inject = [
  '$scope'
  '$state'
  '$stateParams'
]

angular.module('accounts').controller 'ConnectLoginController', ConnectLoginController
