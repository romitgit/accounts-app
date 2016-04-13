'use strict'

{ TC_JWT }   = require '../../core/constants.js'
{ getToken } = require '../../core/token.js'

HomeController = (
  $log
  $state
  $window
  TokenService
  Constants) ->
  
  vm           = this
  vm.title     = 'Home'
  
  init = ->
    unless getToken(TC_JWT)
      $state.go 'MEMBER_LOGIN'
    else
      $window.location = 'https://www.' + Constants.DOMAIN + '/'
    vm
  
  init()
  

HomeController.$inject = [
  '$log'
  '$state'
  '$window'
  'TokenService'
  'Constants'
]

angular.module('accounts').controller 'HomeController', HomeController
