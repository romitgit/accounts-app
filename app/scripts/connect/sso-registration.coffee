'use strict'

{ getSSOProvider, generateSSOUrl } = require '../../../core/auth.js'

SSORegistrationController = (
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

    # TODO uncomment api call when we have the end point for fetching SSO provider for the given email
    # for now it is hard coded to Wipro
    # success = (org) ->
    #   vm.org     = org
    #   vm.success = true
    #   go()

    # failure = (err) ->
    #   vm.loading = false
    #   vm.error   = err.message
    #   $scope.$apply()

    # getSSOProvider(vm.emailOrHandle)
    #   .then(success)
    #   .catch(failure)

    vm.org = 'wipro-adfs'
    go()


  vm.showRegistrationPage = ->
    $log.info 'showRegistrationPage!'
    if vm.app == 'member'
      $state.go 'MEMBER_REGISTRATION', $stateParams
    else
      $state.go 'CONNECT_REGISTRATION', $stateParams

  go = ->
    state = vm.retUrl
    registrationState
    if vm.app == 'member'
      registrationState = 'MEMBER_REGISTRATION'
    else
      registrationState = 'CONNECT_REGISTRATION'
    callbackUrl = $state.href registrationState, {retUrl : state}, { absolute: true }
    authUrl = generateSSOUrl vm.org, callbackUrl
    $log.info 'redirecting to ' + authUrl
    $window.location.href = authUrl;
  
  activate()

  vm

SSORegistrationController.$inject = [
  '$log'
  '$scope'
  '$state'
  '$stateParams'
  '$window'
]

angular.module('accounts').controller 'SSORegistrationController', SSORegistrationController


