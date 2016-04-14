'use strict'

{ logout } = require '../../core/auth.js'

LogoutController = (
    $log
    $location
    $window
    $state
    $timeout
) ->
  vm           = this
  vm.title     = 'Logout'
  vm.error     = false
  vm.loading   = false
  vm.apps      = {}

  $window.loaded = (src) ->
    $log.info 'logged out from '+src
    $log.info vm.apps
    
    handler = () ->
      vm.apps[src] = src

      if vm.apps.member && vm.apps.connect && vm.apps.sample
        if $location.search().retUrl
          redirectUrl = $location.search().retUrl
          $log.info 'redirect back to ' + redirectUrl
          $window.location = redirectUrl

        else
          $log.info 'move to home'
          $state.go 'home'

    $timeout handler, 250

  init = ->
    logout().then (res) ->
      $log.debug res
    vm

  init()

LogoutController.$inject = [
  '$log'
  '$location'
  '$window'
  '$state'
  '$timeout'
]

angular.module('accounts').controller 'LogoutController', LogoutController
