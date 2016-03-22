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
    AuthService
    Constants) ->
  
  vm           = this
  vm.title     = 'Logout'
  vm.error     = false
  vm.loading   = false
  vm.apps      = {}
  vm.logoutUrl = $sce.trustAsResourceUrl(Constants.APP_LOGOUT_URL)

  $window.loaded = (src) ->
    $log.info 'logged out from '+src
    $log.info vm.apps
    $timeout () ->
      vm.apps[src] = src
      if vm.apps.member && vm.apps.connect
        if $location.search().retUrl
          redirectUrl = $location.search().retUrl
          $log.info 'redirect back to ' + redirectUrl
          $window.location = redirectUrl
        else
          $log.info 'move to home'
          $state.go 'home'
      250

  init = ->
    AuthService.logout().then (res) ->
      $log.debug res
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
  'Constants'
]

angular.module('accounts').controller 'LogoutController', LogoutController
