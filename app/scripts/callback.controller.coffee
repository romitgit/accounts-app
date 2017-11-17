'use strict'

{ isAuth0Hosted,  parseResult} = require '../../core/auth.js'
{ setupLoginEventMetrics } = require '../../core/utils.js'
{ redirectTo, generateZendeskReturnUrl, generateReturnUrl, getBaseUrl } = require '../../core/url.js'

CallbackController = (
  $log
  $scope
  $window
  $state
  $stateParams
  UserService
) ->
  
  vm = this
  vm.loading   = false
  vm.init      = false


  vm.baseUrl = getBaseUrl()
  vm.homeUrl = $state.href('HOME', {}, { absolute: true})
  
  vm.loginErrors =
    USERNAME_NONEXISTANT: false
    WRONG_PASSWORD: false
    SOCIAL_LOGIN_ERROR: false

  loginFailure = (error) ->
    $log.warn(error)
    vm.loading = false
    
    if error?.error_description?.toLowerCase() == 'account inactive'
      # redirect to the page to prompt activation 
      $log.info 'redirect to #{vm.confirmActivationUrl}'
      $window.location = vm.confirmActivationUrl
    else
      $log.err(err)
      vm.loginErrors.WRONG_PASSWORD = true
      $state.go 'home'

  loginSuccess = (stateParams) ->
    vm.loading = false
    vm.$stateParams = stateParams
    vm.retUrl = if stateParams.retUrl then decodeURIComponent(stateParams.retUrl) else vm.baseUrl

    # setup login event for analytics tracking
    setupLoginEventMetrics(vm.username)

    if stateParams.redirect_uri
      # OAuth
      $state.go 'OAUTH', $stateParams
    else if $stateParams.return_to
      # Zendesk
      redirectTo generateZendeskReturnUrl(stateParams.return_to)
    else if vm.retUrl
      redirectTo generateReturnUrl(vm.retUrl)
    else
      $state.go 'home'

  init = ->
    if isAuth0Hosted()
       return $state.go 'otherwise'

    parseResult($window.location.search.substr(1))
      .then(loginSuccess)
      .catch(loginFailure)

    vm
  
  init()


CallbackController.$inject = [
  '$log'
  '$scope'
  '$window'
  '$state'
  '$stateParams'
  'UserService'
]

angular.module('accounts').controller 'CallbackController', CallbackController
