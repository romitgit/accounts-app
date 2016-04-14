'use strict'

LoginController = (
  $log
  $state
  $stateParams
  Constants
  Utils) ->
  
  vm = this
  
  isConnectLogin = ->
    # checking with app parameter
    app = $stateParams.app
    if app
      $log.info 'app: '+app
      return app.toLowerCase() == 'connect'
    
    # checking with return url
    retUrl = $stateParams.retUrl
    if retUrl && Utils.isUrl retUrl
      parser = document?.createElement 'a'
      if parser
        parser.href = retUrl
        return parser.hostname.toLowerCase().startsWith('connect.')
    
    false
  
  init = ->
    if isConnectLogin()
      $state.go 'CONNECT_LOGIN', Utils.encodeParams $stateParams
    else
      $state.go 'MEMBER_LOGIN', Utils.encodeParams $stateParams      
    vm
  
  init()


LoginController.$inject = [
  '$log'
  '$state'
  '$stateParams'
  'Constants'
  'Utils'
]

angular.module('accounts').controller 'LoginController', LoginController
