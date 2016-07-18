'use strict'

{ registerUser, getFreshToken } = require '../../../core/auth.js'
{ DOMAIN } = require '../../../core/constants.js'
{ npad } = require '../../../core/utils.js'
_ = require 'lodash'

RegistrationController = ($state, $stateParams, $scope, ISO3166) ->
  vm              = this
  vm.username     = ''
  vm.password     = ''
  vm.error        = false
  vm.errorMessage = 'Error Creating User'
  vm.submit       = null
  vm.loading      = false

  vm.countries = ISO3166.getAllCountryObjects()

  vm.updateCountry = (angucompleteCountryObj) ->
    countryCode = _.get(angucompleteCountryObj, 'originalObject.code', undefined)

    isValidCountry = !_.isUndefined(countryCode)
    vm.registerForm.country.$setValidity('required', isValidCountry)
    vm.isValidCountry = isValidCountry
    if isValidCountry
      vm.country = angucompleteCountryObj.originalObject

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
        country           :
          code: npad(vm.country.code, 3)
          isoAlpha3Code: vm.country.alpha3
          isoAlpha2Code: vm.country.alpha2
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
  '$scope',
  'ISO3166'
]

angular.module('accounts').controller 'ConnectRegistrationController', RegistrationController
