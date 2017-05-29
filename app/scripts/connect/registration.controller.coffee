'use strict'

{ registerUser, getFreshToken } = require '../../../core/auth.js'
{ DOMAIN } = require '../../../core/constants.js'
{ npad } = require '../../../core/utils.js'
{ decodeToken } = require '../../../core/token.js'
_ = require 'lodash'

RegistrationController = ($state, $stateParams, $scope, ISO3166) ->
  vm              = this
  vm.username     = ''
  vm.password     = ''
  vm.error        = false
  vm.errorMessage = 'Error Creating User'
  vm.submit       = null
  vm.loading      = false
  vm.retUrl = $stateParams && $stateParams.retUrl ? null

  vm.countries = ISO3166.getAllCountryObjects()

  vm.auth0User
  if $stateParams.auth0Jwt
    vm.auth0User = decodeToken $stateParams.auth0Jwt
  console.log(vm.auth0User)

  # adds watch to registerForm so that we can update form's state
  $scope.$watch 'vm.registerForm', (registerForm) ->
    if registerForm
      if vm.auth0User && vm.auth0User.given_name
        vm.firstName = vm.auth0User.given_name
        registerForm['first-name'].$setDirty()
      if vm.auth0User && vm.auth0User.family_name
        vm.lastName = vm.auth0User.family_name
        registerForm['last-name'].$setDirty()
      if vm.auth0User && vm.auth0User.email
        vm.email = vm.auth0User.email
        registerForm.email.$setDirty()

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

    profile = null
    if vm.auth0User #SSO user
      ssoUserId = vm.auth0User.user_id
      if ssoUserId
        ssoUserId = ssoUserId.substring ssoUserId.lastIndexOf('|') + 1
      profile =
        name: vm.auth0User.name
        email: vm.auth0User.email
        providerType: 'samplp'
        provider: _.get(vm.auth0User, "identities[0].connection", '')
        userId: ssoUserId

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
