'use strict'

{ DOMAIN }   = require '../../core/constants.js'
{ isAuth0Hosted, getV3Jwt } = require '../../core/auth.js'

HomeController = (
  $log
  $state
  $window
) ->
  vm           = this
  vm.title     = 'Home'
  
  init = ->
    unless !isAuth0Hosted() and getV3Jwt()
      $state.go 'MEMBER_LOGIN'
    else
      $window.location = 'https://www.' + DOMAIN + '/'
    vm
  
  init()

HomeController.$inject = [
  '$log'
  '$state'
  '$window'
]

angular.module('accounts').controller 'HomeController', HomeController
