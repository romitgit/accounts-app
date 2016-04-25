'use strict'

{ getToken, validateClient } = require '../../core/auth.js'
{ isUrl } = require '../../core/url.js'

OAuthController = (
  $log
  $state
  $stateParams
  $window
) ->
  
  vm = this

  # /oauth?client_id&response_type&state&redirect_uri&scope  
  validateParams = ->
    error = undefined
    if !$stateParams.response_type || $stateParams.response_type != 'token'
      error = {type:'unsupported_response_type', desc:'response_type is invalid'}
    else if !$stateParams.redirect_uri || !isUrl($stateParams.redirect_uri)
      $stateParams.redirect_uri = undefined
      error = {type:'invalid_request', desc:'redirect_uri is invalid'}
    else if !$stateParams.client_id
      error = {type:'invalid_request', desc:'client_id is required'}
    
    if error
      $window.location.href = createErrorUrl($stateParams.redirect_uri || '/', error.type, error.desc, $stateParams.state || '')
    error
  
  #access_token=&token_type=bearer&state
  createRedirectUrl = (redirectUrl, state) ->
    url = redirectUrl + '#access_token=' + getToken() + '&token_type=bearer&state=' + state
    return url
  
  createErrorUrl = (redirectUrl, status, message, state) ->
    ###
    https://tools.ietf.org/html/rfc6749#page-26
    400: 'invalid_request'
    401: 'access_denied'
    403: 'unauthorized_client'
    500: 'server_error'
    unsupported_response_type, invalid_scope,  
    ###
    error = ''
    if status == 400
      error = 'invalid_request'
    else if status == 401
      error = 'access_denied'
    else if status == 403
      error = 'unauthorized_client'
    else if status >= 500
      error = 'server_error'
    else
      error = status
    
    url = redirectUrl + '#error=' + error + '&error_description=' + message + '&state=' + state
    return url
  
  init = ->
    err = validateParams()
    if err
      return vm
    
    unless getToken()
      $state.go 'MEMBER_LOGIN', $stateParams
    else
      redirectUrl = $stateParams.redirect_uri || ''
      state = $stateParams.state || ''
      clientId = $stateParams.client_id || ''
      validateClient(clientId, redirectUrl)
        .then (res) ->
          $window.location.href = createRedirectUrl(redirectUrl, state)
        .catch (err) ->
          $log.error(err)
          $window.location.href = createErrorUrl(redirectUrl, err?.response?.status, err?.message, state)
    vm
  
  init()
  

OAuthController.$inject = [
  '$log'
  '$state'
  '$stateParams'
  '$window'
]

angular.module('accounts').controller 'OAuthController', OAuthController
