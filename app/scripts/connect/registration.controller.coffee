'use strict'

{ registerUser, getFreshToken, getOneTimeToken, identifySSOProvider } = require '../../../core/auth.js'
{ DOMAIN, CONNECT_PROJECT_CALLBACK, UTM_SOURCE_CONNECT } = require '../../../core/constants.js'
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
  vm.ssoUser
  vm.retUrl  = $stateParams.retUrl
  vm.auth0Data = $stateParams.auth0Data
  # SSO user data extracted from auth0 login data
  vm.ssoUser = vm.auth0Data?.ssoUserData
  # pre-populated data
  vm.regForm = $stateParams.regForm
  if vm.regForm
    vm.username   = vm.regForm.handle
    vm.firstName  = vm.regForm.firstName
    vm.lastName   = vm.regForm.lastName
    vm.countryObj = ISO3166.getCountryObjFromCountryCode(vm.regForm.country)

  vm.countries = ISO3166.getAllCountryObjects()

  afterActivationURL = $stateParams.retUrl ? 'https://connect.' + DOMAIN
  vm.isConnectProjectFlow = afterActivationURL && afterActivationURL.indexOf(CONNECT_PROJECT_CALLBACK) != -1
  
  # watch form to detect particular changes in it.
  # https://stackoverflow.com/questions/22436501/simple-angularjs-form-is-undefined-in-scope
  $scope.$watch 'registerForm', (registerForm) ->
    vm.onSSORegister vm.ssoUser if vm.ssoUser

  $scope.$watch 'vm.email', (email) ->
    vm.ssoForced = !!(identifySSOProvider vm.email)

  vm.updateCountry = (angucompleteCountryObj) ->
    countryCode = _.get(angucompleteCountryObj, 'originalObject.code', undefined)

    isValidCountry = !_.isUndefined(countryCode)
    vm.registerForm.country.$setValidity('required', isValidCountry)
    vm.isValidCountry = isValidCountry
    vm.country = _.get(angucompleteCountryObj, 'originalObject')

  vm.onCountryBlur = () ->
    isValidCountry = !_.isUndefined(vm.country)
    vm.registerForm.country.$setValidity('required', isValidCountry)
    vm.isCountryDirty = vm.registerForm.country.$dirty
    vm.isValidCountry = isValidCountry

  # SSO Login for registration
  startSSO = ->
    params =
      app: 'connect'
      email: vm.email
      regForm:
        handle: vm.username
        firstName: vm.firstname
        lastName : vm.lastname
        country  : vm.country.code
      retUrl: vm.retUrl
    $state.go 'SSO_LOGIN', params


  vm.submit = ->
    if !vm.ssoUser
      provider = identifySSOProvider vm.email
      if vm.email
        startSSO()
        return

    vm.error = false
    vm.loading = true

    profile = null
    if vm.ssoUser #SSO user
      profile =
        name: vm.ssoUser.name
        email: vm.ssoUser.email
        providerType: 'samlp'
        provider: vm.ssoUser.ssoProvider
        userId: vm.ssoUser.ssoUserId

    config =
      param:
        handle            : vm.username
        firstName         : vm.firstName
        lastName          : vm.lastName
        email             : vm.email
        utmSource         : UTM_SOURCE_CONNECT
        country           :
          code: npad(vm.country.code, 3)
          isoAlpha3Code: vm.country.alpha3
          isoAlpha2Code: vm.country.alpha2
      options:
        afterActivationURL: afterActivationURL

    if profile #if sso registration
      config.param.active = true
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
      if error.message.indexOf('JSON') != -1
        vm.errorMessage = "We weren't able to register you because of a system error. Please try again or contact support@topcoder.com."
      else
        vm.errorMessage = error.message

  registerSuccess = (user) ->

    # move to the sso login if a user is already active and sso user
    if !!user?.active && user?.profile?.providerType == 'samlp'
      stateParams =
        app: 'connect'
        email: vm.email
        retUrl: vm.retUrl
      $state.go 'SSO_LOGIN', stateParams
      return

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
    
    if ssoUser?.firstName
      vm.firstName = ssoUser.firstName
      vm.registerForm?.firstname?.$setDirty()

    if ssoUser?.lastName
      vm.lastName = ssoUser.lastName
      vm.registerForm?.lastname?.$setDirty()

    if ssoUser?.email
      vm.email = ssoUser.email
      vm.registerForm?.email?.$setDirty()

  vm.onSSORegister vm.ssoUser if vm.ssoUser
  
  vm

RegistrationController.$inject = [
  '$state'
  '$stateParams'
  '$scope',
  'ISO3166'
]

angular.module('accounts').controller 'ConnectRegistrationController', RegistrationController
