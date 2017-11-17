'use strict'

{ DOMAIN }   = require '../../core/constants.js'
{ isAuth0Hosted, getV3Jwt, redirectToAuth0} = require '../../core/auth.js'

HomeController = (
  $log
  $state
  $window
) ->
  vm           = this
  vm.title     = 'Home'
  
  init = ->
    redirectToAuth0({})
    unless !isAuth0Hosted() and getV3Jwt()
      # check the current clietn_id to see if it's connect
      target = 'MEMBER_LOGIN'
      if isAuth0Hosted()
        app = window.config?.dict?.signin?.title
        if app and app.toLowerCase() == 'connect' then target = 'CONNECT_LOGIN'
      $state.go target
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
