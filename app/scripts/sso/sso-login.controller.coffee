'use strict'

{ getSSOProvider, generateSSOUrl } = require '../../../core/auth.js'

SSOLoginController = (
  $log
  $scope
  $state
  $stateParams
  $window
) ->
  
  vm               = this
  vm.loading       = false
  vm.success       = false
  vm.error         = ''
  vm.emailOrHandle = ''
  vm.org           = $stateParams.org
  vm.retUrl        = $stateParams.retUrl
  vm.app           = $stateParams.app

  activate = ->
    if vm.org
      go()

  vm.submit = ->
    vm.loading = true

    success = (org) ->
      vm.org     = org
      vm.success = true
      go()

    failure = (err) ->
      vm.loading = false
      vm.error   = err.message
      $scope.$apply()

    getSSOProvider(vm.emailOrHandle)
      .then(success)
      .catch(failure)

  vm.showLoginPage = ->
    $log.info 'showLoginPage!'
    if vm.app == 'member'
      $state.go 'MEMBER_LOGIN', $stateParams
    else
      $state.go 'CONNECT_LOGIN', $stateParams

  go = ->
    state = vm.retUrl
    unless state
      # TODO: home?
      state = $state.href 'home', {}, { absolute: true }
    callbackUrl = $state.href 'SSO_CALLBACK', {retUrl : state}, { absolute: true }
    # 2017.04.12 - the callback does not work without hash bang when getting back from IdP
    callbackUrl = callbackUrl.replace 'sso-callback', '#!/sso-callback'
    authUrl = generateSSOUrl vm.org, callbackUrl
    $log.info 'redirecting to ' + authUrl
    $window.location.href = authUrl;
  
  activate()

  vm

SSOLoginController.$inject = [
  '$log'
  '$scope'
  '$state'
  '$stateParams'
  '$window'
]

angular.module('accounts').controller 'SSOLoginController', SSOLoginController


