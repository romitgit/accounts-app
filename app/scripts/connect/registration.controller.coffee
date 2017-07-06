'use strict'

{ registerUser, getFreshToken, getOneTimeToken } = require '../../../core/auth.js'
{ DOMAIN } = require '../../../core/constants.js'
{ npad } = require '../../../core/utils.js'
{ decodeToken } = require '../../../core/token.js'
_ = require 'lodash'

RegistrationController = ($state, $stateParams, $scope, ISO3166) ->
  vm              = this
  vm.termsUrl     = 'https://connect.' + DOMAIN + '/terms'
  vm.privacyUrl   = 'https://www.' + DOMAIN + '/community/how-it-works/privacy-policy/'
  vm.username     = ''
  vm.password     = ''
  vm.error        = false
  vm.errorMessage = 'Error Creating User'
  vm.submit       = null
  vm.loading      = false
  vm.isValidCountry    = false
  vm.isCountryDirty    = false
  vm.isSSORegistration = false
  vm.ssoUser
  vm.retUrl = $stateParams && $stateParams.retUrl ? null

  vm.countries = ISO3166.getAllCountryObjects()

  afterActivationURL = $stateParams.retUrl ? 'https://connect.' + DOMAIN

  vm.updateCountry = (angucompleteCountryObj) ->
    countryCode = _.get(angucompleteCountryObj, 'originalObject.code', undefined)

    isValidCountry = !_.isUndefined(countryCode)
    vm.registerForm.country.$setValidity('required', isValidCountry)
    vm.isValidCountry = isValidCountry
    vm.country = _.get(angucompleteCountryObj, 'originalObject')

  vm.onCountryBlur = () ->
    isValidCountry = !_.isUndefined(vm.country)
    vm.registerForm.country.$setValidity('required', isValidCountry)
    vm.isCountryDirty = true
    vm.isValidCountry = isValidCountry

  vm.submit = ->
    vm.error = false
    vm.loading = true

    profile = null
    if vm.ssoUser #SSO user
      profile =
        name: vm.ssoUser.name
        email: vm.ssoUser.email
        providerType: 'samplp'
        provider: vm.ssoUser.ssoProvider
        userId: vm.ssoUser.ssoUserId

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
      options:
        afterActivationURL: afterActivationURL

    if profile #if sso registration
      config.param.profile = profile
    else # set password only if it is NON SSO registration
      config.param.credential =
        password : vm.password
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

  vm.ssoRegister = ->
    vm.isSSORegistration = true

  vm.ssoRegisterCancel = ->
    vm.isSSORegistration = false

  vm.onSSORegister = (ssoUser) ->
    vm.isSSORegistration = false
    vm.ssoUser = ssoUser
    
    if ssoUser && ssoUser.firstName
      vm.firstName = ssoUser.firstName
      vm.registerForm['first-name'].$setDirty()

    if ssoUser && ssoUser.lastName
      vm.lastName = ssoUser.lastName
      vm.registerForm['last-name'].$setDirty()

    if ssoUser && ssoUser.email
      vm.email = ssoUser.email
      vm.registerForm.email.$setDirty()

  vm

RegistrationController.$inject = [
  '$state'
  '$stateParams'
  '$scope',
  'ISO3166'
]

angular.module('accounts').controller 'ConnectRegistrationController', RegistrationController
