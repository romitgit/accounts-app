'use strict'

{ setToken } = require '../../../core/token.js'
{ generateReturnUrl, redirectTo } = require '../../../core/url.js'
{ getSSOProvider, ssoLogin, identifySSOProvider, getNewJWT, getFreshToken } = require '../../../core/auth.js'
{ V3_JWT, V2_JWT, V2_SSO, AUTH0_REFRESH, AUTH0_JWT, ZENDESK_JWT } = require '../../../core/constants.js'

SSOLoginController = (
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
    getJwtSuccess = (jwt) ->
      $scope.$apply () ->
        vm.loading = false
      console.debug 'already logged in...redirecting...'
      if jwt && vm.retUrl
        redirectTo generateReturnUrl(vm.retUrl)
    vm.loading = true
    getFreshToken()
      .then(getJwtSuccess)
      .catch(() ->
        $scope.$apply () ->
          vm.loading = false
      )

  setV3Tokens = ({token, zendeskJwt}) ->
    console.debug 'received v3 tokens'
    setToken(V3_JWT, token || '')
    setToken(ZENDESK_JWT, zendeskJwt || '')
    $scope.$apply () ->
      vm.loading = false
      vm.success = true
    error = redirectTo generateReturnUrl(vm.retUrl)
    if error
      vm.error = 'Invalid URL is assigned to the return-URL.'

  vm.submit = ->
    vm.loading = true

    login = (org) ->
      console.debug 'found SSO user in tc database for provider ' + org
      if org && org == vm.org
        setToken(AUTH0_JWT, vm.auth0Data.idToken)
        setToken(AUTH0_REFRESH, vm.auth0Data.refreshToken)
        console.debug 'getting v3 tokens'
        getNewJWT()
          .then(setV3Tokens)
          .catch(failure)
      else # will this ever land here?
        vm.loading = false
        vm.error = 'SSO provider details does not match'

    register = () ->
      console.debug 'SSO user not found in TC database...redirecting to registration page'
      # TODO Connect registration needed to updated for the new SSO login flow
      registrationState = if vm.app == 'member' then 'MEMBER_REGISTRATION' else 'CONNECT_REGISTRATION'
      $state.go registrationState, {
        auth0Data: vm.auth0Data,
        retUrl : vm.retUrl
      }

    success = (result) ->
      console.debug 'login successful using auth0'
      vm.auth0Data = result.data
      console.debug 'validating if we have user in TC database...'
      getSSOProvider(vm.emailOrHandle)
        .then(login)
        .catch(register)

    failure = (err) ->
      vm.loading = false
      vm.error   = err.message
      $scope.$apply()

    provider = identifySSOProvider(vm.emailOrHandle)
    if provider
      vm.org = provider
      ssoLogin(vm.org)
        .then(success)
        .catch(failure)

  vm.showLoginPage = ->
    $log.info 'showLoginPage!'
    if vm.app == 'member'
      $state.go 'MEMBER_LOGIN', $stateParams
    else
      $state.go 'CONNECT_LOGIN', $stateParams
  
  activate()

  vm

SSOLoginController.$inject = [
  '$log'
  '$scope'
  '$state'
  '$stateParams'
  '$window'
]

angular.module('accounts').controller 'SSOLoginController', SSOLoginController


