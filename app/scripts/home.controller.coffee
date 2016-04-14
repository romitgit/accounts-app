'use strict'

{ TC_JWT } = require '../../core/constants.js'
{ decodeToken } = require '../../core/token.js'
{ isLoggedIn } = require '../../core/auth.js'

HomeController = (
  $state
  AuthService
  TokenService) ->
  
  vm           = this
  vm.title     = 'Home'
  vm.account   = null
  vm.loading   = false
  
  vm.logout = ->
    $state.go 'logout'
  
  vm.isLoggedIn = ->
     isLoggedIn()
  
  init = ->
    jwt = localStorage.getItem(TC_JWT)

    unless jwt
      $state.go 'MEMBER_LOGIN'
    else
      vm.account = decodeToken(jwt).handle

    vm
  
  init()
  

HomeController.$inject = [
  '$state'
  'AuthService'
  'TokenService'
]

angular.module('accounts').controller 'HomeController', HomeController
