'use strict'

{ DOMAIN }   = require '../../../core/constants.js'
{ login, resetPassword, getV3Jwt } = require '../../../core/auth.js'
{ removeToken } = require '../../../core/token.js'
{ generateReturnUrl, redirectTo } = require '../../../core/url.js'

ResetPasswordController = ($stateParams, $state, $scope) ->
  vm          = this
  vm.password = ''
  vm.error    = ''
  vm.loading  = false
  vm.passwordResetDone = false
  vm.loggedIn = false
  token       = $stateParams.token
  handle      = $stateParams.handle
  vm.baseUrl  = "https://connect.#{DOMAIN}"
  vm.loginUrl = $state.href('CONNECT_LOGIN', {}, { absolute: true })
  vm.retUrl   = if $stateParams.retUrl then decodeURIComponent($stateParams.retUrl) else vm.baseUrl  

  vm.submit = ->
    vm.error = false
    vm.loading  = true

    resetPassword(handle, token, vm.password).then(loginUser, failure)

  # Login the user
  loginUser = ->
    $scope.$apply ->
      vm.passwordResetDone = true
    # uses username/password from stateParams, passed from registration page
    options =
      username: handle
      password: vm.password
    # call login api
    login(options).then(loginSuccess, loginFailure)

  # Handles the login success, redirects user to the return URL
  loginSuccess = ->
    jwt = getV3Jwt()

    unless jwt
      $scope.$apply ->
        vm.passwordResetDone = false
        vm.error = true
        vm.message = 'Unable to log you in automatically. Please try logging in using \'Log in\' link.'
    else if vm.retUrl
      $scope.$apply ->
        vm.passwordResetDone = false
        vm.loggedIn = true
      redirectTo generateReturnUrl(vm.retUrl)
    else
      $scope.$apply ->
        vm.passwordResetDone = false
        vm.loggedIn = true
      $state.go 'home'

  # Handles login failure, redirects user to login page to do explicit login
  loginFailure = ->
    $scope.$apply ->
      vm.loading  = false
    $state.go 'CONNECT_LOGIN', { passwordReset: true }

  failure = (error) ->
    $scope.$apply ->
      vm.error    = error.message
      vm.loading  = false

  vm

ResetPasswordController.$inject = [
  '$stateParams'
  '$state'
  '$scope'
]

angular.module('accounts').controller 'ConnectResetPasswordController', ResetPasswordController


