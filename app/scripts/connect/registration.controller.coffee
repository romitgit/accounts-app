'use strict'

{ registerUser, getFreshToken, getOneTimeToken } = require '../../../core/auth.js'
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

  afterActivationURL = $stateParams.retUrl ? 'https://connect.' + DOMAIN

  vm.updateCountry = (angucompleteCountryObj) ->
    countryCode = _.get(angucompleteCountryObj, 'originalObject.code', undefined)

    isValidCountry = !_.isUndefined(countryCode)
    vm.registerForm.country.$setValidity('required', isValidCountry)
    vm.isValidCountry = isValidCountry
    if isValidCountry
      vm.country = angucompleteCountryObj.originalObject
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
    # registerSuccess({ id: 40152526})

  registerError = (error) ->
    $scope.$apply ->
      vm.error        = true
      vm.loading      = false
      vm.errorMessage = error.message

  registerSuccess = (user) ->
    # options =
    #   username: vm.username
    #   password: vm.password
    
    # getOneTimeToken(options).then(tokenSuccess, registerError)
    stateParams =
      email              : vm.email
      username           : vm.username
      password           : vm.password
      userId             : user.id
      afterActivationURL : afterActivationURL

    $state.go 'CONNECT_PIN_VERIFICATION', stateParams

  # following method could be used if we want to procure the temp token before
  # landing user on pin verificaiton screen
  # tokenSuccess = ({ token }) ->
  #   stateParams =
  #     email: vm.email
  #     username: vm.username
  #     password: vm.password
  #     tempToken : token
  #   $state.go 'CONNECT_PIN_VERIFICATION',stateParams

  vm

RegistrationController.$inject = [
  '$state'
  '$stateParams'
  '$scope',
  'ISO3166'
]

angular.module('accounts').controller 'ConnectRegistrationController', RegistrationController
