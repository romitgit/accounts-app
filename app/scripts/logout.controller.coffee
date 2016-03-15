'use strict'

LogoutController = (
    $log
    $rootScope
    $location
    $window
    $state
    $stateParams
    $sce
    $timeout
    AuthService) ->
  
  vm           = this
  vm.title     = 'Logout'
  vm.error     = false
  vm.loading   = false
  vm.apps      = {}
  vm.logoutUrl = $sce.trustAsResourceUrl(process.env.APP_LOGOUT_URL)

  $window.loaded = (src) ->
    $log.info 'logged out from '+src
    $log.info vm.apps
    $timeout () ->
      vm.apps[src] = src
      if vm.apps.member && vm.apps.connect
        if $stateParams.retUrl
          redirectUrl = $stateParams.retUrl
          $log.info 'redirect back to ' + redirectUrl
          $window.location = redirectUrl
        else
          $log.info 'moving to home'
          $state.go 'home'
      500

  init = ->
    AuthService.logout()
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
]

angular.module('accounts').controller 'LogoutController', LogoutController
