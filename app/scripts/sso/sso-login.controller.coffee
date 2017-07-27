'use strict'

{ setToken } = require '../../../core/token.js'
{ generateReturnUrl, redirectTo } = require '../../../core/url.js'
{ getSSOProvider, generateSSOUrl, ssoLogin, identifySSOProvider, getNewJWT } = require '../../../core/auth.js'
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
    if vm.org
      go()

  setV3Tokens = ({token, zendeskJwt}) ->
    console.log 'received v3 tokens'
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
      console.log 'found SSO user in tc database for provider ' + org
      if org # should we validate org against provider
        setToken(AUTH0_JWT, vm.auth0Data.idToken)
        setToken(AUTH0_REFRESH, vm.auth0Data.refreshToken)
        console.log 'getting v3jwt'
        getNewJWT()
          .then(setV3Tokens)
          .catch(failure)

    register = () ->
      console.log 'SSO user not found in TC database...redirecting to registration page'
      $state.go 'MEMBER_REGISTRATION', {
        ssoUser : vm.auth0Data.ssoUserData,
        auth0Data: vm.auth0Data,
        retUrl : vm.retUrl
      }

    success = (result) ->
      console.log 'login successful using auth0'
      console.log result
      vm.auth0Data = result.data
      console.log 'checking if we have user in TC database'
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


