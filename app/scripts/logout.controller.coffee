'use strict'

{ logout } = require '../../core/auth.js'

LogoutController = (
    $log
    $state
    $stateParams
    Utils) ->
  
  vm           = this
  vm.title     = 'Logout'
  vm.error     = false
  vm.loading   = false

  init = ->
    logout().then (res) ->
      $log.debug res
    if $stateParams.retUrl
      Utils.redirectTo Utils.generateReturnUrl(decodeURIComponent($stateParams.retUrl))
    else
      $state.go 'home'
    vm

  init()

LogoutController.$inject = [
  '$log'
  '$state'
  '$stateParams'
  'Utils'
]

angular.module('accounts').controller 'LogoutController', LogoutController
