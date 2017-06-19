'use strict'

{ DOMAIN }   = require '../../../core/constants.js'
{ getFreshToken, login, verifyPIN, getV3Jwt, updatePrimaryEmail }    = require '../../../core/auth.js'
{ decodeToken } = require '../../../core/token.js'
{ getLoginConnection } = require '../../../core/utils.js'
{ generateReturnUrl, redirectTo } = require '../../../core/url.js'

ConnectPinVerificationController = (
  $scope
  $state
  $stateParams
) ->
  vm           = this
  vm.email  = $stateParams.email
  vm.pin  = ''
  vm.error     = false
  vm.loading   = false
  vm.init      = false
  vm.emailEditMode = false
  vm.$stateParams = $stateParams
  
  vm.baseUrl = "https://connect.#{DOMAIN}"
  vm.registrationUrl   = $state.href('CONNECT_REGISTRATION', { activated: true }, { absolute: true })
  vm.forgotPasswordUrl = $state.href('CONNECT_FORGOT_PASSWORD', { absolute: true })
  vm.retUrl = if $stateParams.retUrl then decodeURIComponent($stateParams.retUrl) else vm.baseUrl  

  vm.submit = ->
    activateUser(vm.email, vm.pin)

  loginFailure = (error) ->
    $scope.$apply ->
      vm.error   = true
      vm.loading = false

  loginSuccess = ->
    jwt = getV3Jwt()
    console.log 'jwt=>' + jwt

    unless jwt
      vm.error = true
    else if vm.retUrl
      redirectTo generateReturnUrl(vm.retUrl)
    else
      $state.go 'home'

  activateUser = (email, pin) ->
    vm.error   = false
    vm.loading = true

    
    verifyPIN(pin).then(loginSuccess, loginFailure)

  vm.toggleEmailEdit = () ->
    console.log('Editing mode enabled..')
    vm.emailEditMode = true

  vm.updateEmailAndResendPIN = () ->
    vm.emailEditMode = false
    token = getV3Jwt()
    console.log 'decodedTOken=> ' + JSON.stringify(decodeToken(token))
    userId = decodeToken(token).userId
    console.log 'Updating primary email for user ' + userId
    updatePrimaryEmail(userId, vm.email).then(updateEmailSuccess, updateEmailFailure)

  updateEmailSuccess = () ->
    # make email field non editable again
    console.log('updateEmailSuccess')

  updateEmailFailure = () ->
    # show error in the form
    console.log('updateEmailFailure')

  init = ->
    { handle, email, password } = $stateParams

    getJwtSuccess = (jwt) ->
      if jwt && vm.retUrl
        redirectTo generateReturnUrl(vm.retUrl)
      else if (handle || email) && password
        callLogin(handle || email, password)

    # getFreshToken().then(getJwtSuccess)

    vm

  init()


ConnectPinVerificationController.$inject = [
  '$scope'
  '$state'
  '$stateParams'
]

angular.module('accounts').controller 'ConnectPinVerificationController', ConnectPinVerificationController
