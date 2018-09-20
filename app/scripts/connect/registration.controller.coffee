'use strict'

{ registerUser, getFreshToken, getOneTimeToken, identifySSOProvider } = require '../../../core/auth.js'
{ DOMAIN, CONNECT_PROJECT_CALLBACK, UTM_SOURCE_CONNECT } = require '../../../core/constants.js'
{ npad } = require '../../../core/utils.js'
{ decodeToken } = require '../../../core/token.js'
{ decodeToken } = require '../../../core/token.js'
_ = require 'lodash'

ConnectRegistrationController = ($state, $stateParams, $scope, ISO3166, UserService) ->
  vm              = this
  vm.termsUrl     = 'https://connect.' + DOMAIN + '/terms'
  vm.privacyUrl   = 'https://www.' + DOMAIN + '/community/how-it-works/privacy-policy/'
  vm.custommerStoriesUrl = 'https://www.topcoder.com/about/customer-stories/'
  vm.username     = ''
  vm.password     = ''
  vm.error        = false
  vm.errorMessage = ''
  vm.submit       = null
  vm.loading      = false
  vm.isValidCountry    = false
  vm.isCountryDirty    = false
  vm.ssoUser
  vm.retUrl  = $stateParams.retUrl
  vm.auth0Data = $stateParams.auth0Data
  vm.screenType = "register"
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
      if provider
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

    updateInfoConfig =
      param: [
        traitId: vm.username
        categoryName: 'Customer Information'
        traits:
          data: [
            businessPhone: vm.phone
            title: vm.title
            companyName: vm.companyName
            companySize: vm.companySize
          ]
      ]

    if profile #if sso registration
      config.param.active = true
      config.param.profile = profile
    else # set password only if it is NON SSO registration
      config.param.credential =
        password : vm.password
    registerUser(config, updateInfoConfig).then(registerSuccess, registerError)
    # registerSuccess({ id: 40152526})
    vm.reRender()

  registerError = (error) ->
    $scope.$apply ->
      vm.error        = true
      vm.loading      = false
      if error.message.indexOf('JSON') != -1
        vm.errorMessage = "We weren't able to register you because of a system error. Please try again or contact support@topcoder.com."
      else
        vm.errorMessage = error.message
    vm.reRender()

  vm.goToLogin = ->
    stateParams =
        retUrl: vm.retUrl
    $state.go 'CONNECT_LOGIN', stateParams

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

  vm.usernameIsFree = (value) ->
    UserService.validateHandle value
      .then (res) ->
        vm.usernameErrorMessage = null
        if !res.valid
          switch res.reasonCode
            when 'INVALID_LENGTH' then vm.usernameErrorMessage = 'That username is not the correct length or format.'
            when 'INVALID_FORMAT' then vm.usernameErrorMessage = 'That username is not the correct length or format.'
            when 'INVALID_HANDLE' then vm.usernameErrorMessage = 'That username is not allowed.'
            when 'ALREADY_TAKEN' then vm.usernameErrorMessage = 'That username is already taken.'
            else vm.usernameErrorMessage = 'That username is not the correct length or format.'
        vm.reRender()

  vm.emailIsAvailable = (value) ->
    UserService.validateEmail value
      .then (res) ->
        vm.emailErrorMessage = null
        if !res.valid
          switch res.reasonCode
            when 'ALREADY_TAKEN' then vm.emailErrorMessage = 'That email address is already taken.'
            when 'INVALID_EMAIL' then vm.emailErrorMessage = 'Please enter a valid email address.'
            when 'INVALID_LENGTH' then vm.emailErrorMessage = 'Email address should be 100 characters or less.'
            else vm.emailErrorMessage = 'Please enter a valid email address.'
        vm.reRender()
  
  vm

ConnectRegistrationController.$inject = [
  '$state'
  '$stateParams'
  '$scope'
  'ISO3166'
  'UserService'
]

angular.module('accounts').controller 'ConnectRegistrationController', ConnectRegistrationController
