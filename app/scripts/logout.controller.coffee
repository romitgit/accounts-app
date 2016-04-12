'use strict'

{ logout } = require '../../core/auth.js'

LogoutController = (
    $log
    $rootScope
    $location
    $window
    $state
    $stateParams
    $sce
    $timeout
    AuthService
    Utils
    Constants) ->
  
  vm           = this
  vm.title     = 'Logout'
  vm.error     = false
  vm.loading   = false

  init = ->
    AuthService.logout().then (res) ->
      $log.debug res
    if $stateParams.retUrl
      redirectUrl = Utils.generateReturnUrl $stateParams.retUrl
      $log.info 'redirect back to ' + redirectUrl
      $window.location = redirectUrl
    else
      $state.go 'home'
    vm

  init()

LogoutController.$inject = [
  '$log'
  '$rootScope'
  '$location'
  '$window'
  '$state'
  '$stateParams'
  '$sce'
  '$timeout'
  'AuthService'
  'Utils'
  'Constants'
]

angular.module('accounts').controller 'LogoutController', LogoutController
