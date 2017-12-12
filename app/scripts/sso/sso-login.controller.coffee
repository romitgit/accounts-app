'use strict'

{ setToken } = require '../../../core/token.js'
{ generateReturnUrl, redirectTo } = require '../../../core/url.js'
{ getSSOProvider, ssoLogin, identifySSOProvider, getNewJWT, getFreshToken } = require '../../../core/auth.js'
{ V3_JWT, V2_JWT, V2_SSO, AUTH0_REFRESH, AUTH0_JWT, ZENDESK_JWT, DOMAIN } = require '../../../core/constants.js'

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
  vm.emailOrHandle = if !!$stateParams.email then $stateParams.email else ''
  vm.baseUrl       = "https://www.#{DOMAIN}"
  vm.org           = ''
  vm.retUrl        = if $stateParams.retUrl then $stateParams.retUrl else vm.baseUrl
  vm.app           = $stateParams.app
  vm.regForm       = $stateParams.regForm

  activate = ->
    getJwtSuccess = (jwt) ->
      $scope.$apply () ->
        vm.loading = false
        vm.success = true
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
    error = redirectTo generateReturnUrl(vm.retUrl)
    $scope.$apply () ->
      vm.loading = false
      if error
        vm.error = 'Invalid URL is assigned to the return-URL.'
      else
        vm.success = true

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
      registrationState = if vm.app == 'connect' then 'CONNECT_REGISTRATION' else 'MEMBER_REGISTRATION'
      $state.go registrationState, {
        auth0Data : vm.auth0Data,
        regForm : vm.regForm,
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
    else
      vm.error = 'Sorry!! Your SSO provider is not yet supported.'
      vm.loading = false

  vm.showLoginPage = ->
    $log.info 'showLoginPage!'
    if vm.app == 'connect'
      $state.go 'CONNECT_LOGIN', $stateParams
    else
      $state.go 'MEMBER_LOGIN', $stateParams
  
  if vm.emailOrHandle
    vm.submit()

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


