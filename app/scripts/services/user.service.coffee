'use strict'

{ API_URL } = require '../../../core/constants.js'

UserService = (
  $log
  $http
) ->
  # /users/validateEmail
  validateEmail = (email) ->    
    config =
      method: 'GET'
      url: "#{API_URL}/users/validateEmail?email=#{encodeURIComponent(email)}"
      cache: false
      skipAuthorization: true
    
    success = (res) ->
      res.data?.result?.content
   
    $http(config).then(success)

  # /users/validateHandle
  validateHandle = (handle) ->
    config =
      method: 'GET'
      url: "#{API_URL}/users/validateHandle?handle=#{encodeURIComponent(handle)}"
      cache: false
      skipAuthorization: true
    
    success = (res) ->
      res.data?.result?.content
   
    $http(config).then(success)

  validateSocialProfile = (userId, provider) ->
    config =
      method: 'GET'
      url: "#{API_URL}/users/validateSocial?socialUserId=#{userId}&socialProvider=#{encodeURIComponent(provider)}"
      cache: false
      skipAuthorization: true
    success = (res) ->
      res.data?.result?.content
   
    $http(config).then(success)

  # expose
  validateEmail : validateEmail
  validateHandle : validateHandle
  validateSocialProfile : validateSocialProfile
  
  
###
  var _config = {
      cache: false,
      skipAuthorization: true
  }
  function validateUserEmail(email) {

      return api.all('users').withHttpConfig(_config).customGET('validateEmail', {email: email})
    }

###

UserService.$inject = [
  '$log'
  '$http'
]

angular.module('accounts').factory 'UserService', UserService
