'use strict'

{ DOMAIN }   = require '../../core/constants.js'
{ getV3Jwt } = require '../../core/auth.js'

HomeController = (
  $log
  $state
  $window
) ->
  vm           = this
  vm.title     = 'Home'
  
  init = ->
    unless getV3Jwt()
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
