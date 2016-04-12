'use strict'

HomeController = (
  $log
  $state
  $window
  TokenService
  Constants) ->
  
  vm           = this
  vm.title     = 'Home'
  
  init = ->
    jwt = TokenService.getAppirioJWT()
    unless jwt
      $state.go 'MEMBER_LOGIN'
    else
      $window.location = 'https://www.' + Constants.DOMAIN + '/'
    vm
  
  init()
  

HomeController.$inject = [
  '$log'
  '$state'
  '$window'
  'TokenService'
  'Constants'
]

angular.module('accounts').controller 'HomeController', HomeController
