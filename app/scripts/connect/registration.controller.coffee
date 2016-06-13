'use strict'

{ registerUser, getFreshToken } = require '../../../core/auth.js'
{ DOMAIN } = require '../../../core/constants.js'

RegistrationController = ($state, $stateParams, $scope) ->
  vm              = this
  vm.username     = ''
  vm.password     = ''
  vm.error        = false
  vm.errorMessage = 'Error Creating User'
  vm.submit       = null
  vm.loading      = false

  afterActivationURL = $stateParams.returnUrl ? 'https://connect.' + DOMAIN
  vm.submit = ->
    vm.error = false
    vm.loading = true

    config =
      param:
        handle            : vm.username
        firstName         : vm.firstName
        lastName          : vm.lastName
        email             : vm.email
        utmSource         : 'connect'
        credential        :
          password        : vm.password
      options:
        afterActivationURL: afterActivationURL

    registerUser(config).then(registerSuccess, registerError)

  registerError = (error) ->
    $scope.$apply ->
      vm.error        = true
      vm.loading      = false
      vm.errorMessage = error.message

  registerSuccess = ->
    $state.go 'CONNECT_REGISTRATION_SUCCESS'

  vm

RegistrationController.$inject = [
  '$state'
  '$stateParams'
  '$scope'
]

angular.module('accounts').controller 'ConnectRegistrationController', RegistrationController
