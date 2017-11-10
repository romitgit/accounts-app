'use strict'

{ DOMAIN, V3_TEMP_JWT, CONNECT_PROJECT_CALLBACK, UTM_SOURCE_CONNECT }   = require '../../../core/constants.js'
{ getFreshToken, login, verifyPIN, getV3Jwt, getOneTimeToken, updatePrimaryEmail, resendActivationCode }    = require '../../../core/auth.js'
{ decodeToken, setToken, getToken, isTokenExpired, removeToken } = require '../../../core/token.js'
{ getLoginConnection } = require '../../../core/utils.js'
{ generateReturnUrl, redirectTo } = require '../../../core/url.js'

ConnectPinVerificationController = (
  $scope
  $state
  $stateParams
) ->
  vm           = this
  vm.email  = $stateParams.email
  vm.emailBackup = vm.email
  vm.pin  = ''
  vm.error     = false
  vm.loading   = false
  vm.init      = false
  vm.emailEditMode = false
  vm.emailError = false
  vm.pinError   = false
  vm.$stateParams = $stateParams
  
  # TODO: check if this needs to change
  vm.baseUrl = "https://connect.#{DOMAIN}"
  vm.loginUrl   = $state.href('CONNECT_LOGIN', { activated: true }, { absolute: true })
  vm.retUrl = if $stateParams.afterActivationURL then decodeURIComponent($stateParams.afterActivationURL) else vm.baseUrl  
  vm.isConnectProjectFlow = vm.retUrl && vm.retUrl.indexOf(CONNECT_PROJECT_CALLBACK) != -1

  # Submits the form
  vm.submit = ->
    activateUser(vm.pin)

  # Activates the user by verifying the PIN, also login the user if activated
  activateUser = (pin) ->
    vm.error      = false
    vm.pinError   = false
    vm.emailError = false
    vm.loading    = true
    vm.message    = null
    vm.emailEditSuccess = false

    verifyPIN(pin, UTM_SOURCE_CONNECT).then(loginUser, verifyPINFailure)

  # Handles the error in verifying/activating account
  verifyPINFailure = (error) ->
    $scope.$apply ->
      vm.error    = true
      vm.pinError = true
      vm.loading  = false
      vm.message  = 'That PIN is incorrect. Please check that you entered the one you received.'
      if error.status == 400 && error.message.indexOf('has been activated')  != -1
        vm.message = 'User is already activated. Please login.'

  # Login the user
  loginUser = ->
    $scope.$apply ->
      vm.activated = true
    # Removes the temp token from the cookies/local storage
    removeToken(V3_TEMP_JWT)
    # uses username/password from stateParams, passed from registration page
    options =
      username: vm.$stateParams.username
      password: vm.$stateParams.password
    # call login api
    login(options).then(loginSuccess, loginFailure)

  # Handles the login success, redirects user to the return URL
  loginSuccess = ->
    jwt = getV3Jwt()

    unless jwt
      $scope.$apply ->
        vm.activated = false
        vm.error = true
        vm.message = 'Unable to log you in automatically. Please try login using login link.'
    else if vm.retUrl
      $scope.$apply ->
        vm.activated = false
        vm.loggedIn = true
      redirectTo generateReturnUrl(vm.retUrl)
    else
      $scope.$apply ->
        vm.activated = false
        vm.loggedIn = true
      $state.go 'home'

  # Handles login failure 
  loginFailure = ->
    vm.error = true
    vm.loading = false
    vm.message = 'Unable to log you in automatically. Please try login using login link.'

  # Toggles the Email Edit form
  vm.toggleEmailEdit = () ->
    vm.error = false
    if vm.emailEditMode
      vm.email = vm.emailBackup
    else
      vm.emailBackup = vm.email
    vm.emailEditMode = !vm.emailEditMode

  # Updates email and resends activation PIN
  vm.updateEmailAndResendPIN = () ->
    vm.loading = true
    vm.message = null
    vm.error = false
    vm.emailError = false
    vm.pinError   = false

    # authorize user to get temp token
    # updates email
    # resend activation pin
    authorizeInactiveUser()
      .then(updateEmail)
      .then(resendPIN)
      .then(
        () ->
          console.log 'Successfully updated email address and resent PIN'
          $scope.$apply ->
            vm.emailEditMode = false
            vm.loading = false
            vm.emailEditSuccess = true
      )
      .catch(updateEmailFailure)

  # Authorizes the inactive user and gets the temp token
  authorizeInactiveUser = () ->
    # retrieve token from cookie/local storage
    tempToken = getToken(V3_TEMP_JWT)
    if tempToken
      console.log 'isTokenExpired: ' + isTokenExpired(tempToken)
    else
      console.log 'No temp token found'

    # uses userId and password combo from state params, passed from registration page
    options =
      userId : vm.$stateParams.userId
      password: vm.$stateParams.password
    # api call
    getOneTimeToken(options.userId, options.password)
    .then((token) ->
      # saves the temp token in cookie/local storage
      setToken(V3_TEMP_JWT, token)
      token
    )
    .catch((error) ->
      # if we receive error saying token is already issued, use the token from cookies/local storage
      if error.status == 400 && error.message.indexOf('been issued') != -1 && tempToken
        # resolve promise with token from cookies/local storage
        Promise.resolve(tempToken)
    )

  # Call API to update user's meail
  updateEmail = (token) ->
    updatePrimaryEmail(vm.$stateParams.userId, vm.email, token)

  # Call API to resend Activation code
  resendPIN = () ->
    resendActivationCode(vm.$stateParams.userId, vm.retUrl)

  # Handles error in updating email
  updateEmailFailure = (error) ->
    # show error in the form
    $scope.$apply ->
      vm.error = true
      vm.emailError = true
      vm.message = 'Currently we can\'t update your email'
      if error.status == 400 && error.message.indexOf('has already been registered')  != -1
        vm.message = 'Email is already in use, please use different email address'
      if error.status == 400 && error.message.indexOf('has been activated')  != -1
        vm.message = 'User is already activated. Please login.'
      vm.loading = false
      vm.emailEditMode = true

  init = ->
    # TODO we can load temp JWT token from local storage, if there exists one
    # once we have the token we can pre-fill the form, allowing user to directly access this page
    vm

  init()


ConnectPinVerificationController.$inject = [
  '$scope'
  '$state'
  '$stateParams'
]

angular.module('accounts').controller 'ConnectPinVerificationController', ConnectPinVerificationController
