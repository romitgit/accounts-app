'use strict'

{ getToken } = require '../../connector/connector-wrapper.js'
{ decodeToken } = require '../../core/token.js'

HomeController = (
  $log
  $rootScope
  $state
  $scope
  AuthService
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
      $state.go 'MEMBER_LOGIN'
    else
      vm.account = TokenService.decodeToken().handle

    getToken().then (token) ->
      $scope.$apply ->
        vm.iframeAccount = decodeToken(token).handle

    vm
  
  init()
  

HomeController.$inject = [
  '$log'
  '$rootScope'
  '$state'
  '$scope'
  'AuthService'
  'TokenService'
]

angular.module('accounts').controller 'HomeController', HomeController
