'use strict'

HomeController = (
  $log
  $rootScope
  $state
  TokenService) ->
  
  vm           = this
  vm.title     = 'Home'
  vm.account   = null
  vm.loading   = false
  
  vm.logout = ->
    $state.go 'logout'
  
  vm.isLoggedIn = ->
     AuthService.isLoggedIn()
  
  init = ->
    jwt = TokenService.getAppirioJWT()
    unless jwt
      $state.go 'login'
    else
      vm.account = TokenService.decodeToken().handle
    vm
  
  init()
  

HomeController.$inject = [
  '$log'
  '$rootScope'
  '$state'
  'TokenService'
]

angular.module('accounts').controller 'HomeController', HomeController
