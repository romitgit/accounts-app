'use strict'

TCLoginController = (
  $log
  $scope
  $rootScope
  $location
  $window
  $state
  $stateParams
  $timeout
  $authService
  AuthService
  TokenService
  UserService
  Utils
  Constants) ->
  
  vm = this
  vm.loading   = false
  vm.init      = false
  vm.retUrl    =  decodeURIComponent($stateParams.retUrl)
  
  vm.registrationUrl      = 'https://www.' + Constants.DOMAIN + '/register/'
  vm.forgotPasswordUrl    = 'https://www.' + Constants.DOMAIN + '/reset-password/'
  vm.accountInactiveUrl   = 'https://www.' + Constants.DOMAIN + '/account-inactive/'
  vm.confirmActivationUrl = 'https://www.' + Constants.DOMAIN + '/registered-successfully/'
  vm.$stateParams = $stateParams
  vm.loginErrors = 
    USERNAME_NONEXISTANT: false
    WRONG_PASSWORD: false
    SOCIAL_LOGIN_ERROR: false
  
  vm.socialLogin = (provider) ->
    # loading
    vm.loading = true
    # clear error flags
    vm.loginErrors.USERNAME_NONEXISTANT = false
    vm.loginErrors.WRONG_PASSWORD = false
    vm.loginErrors.SOCIAL_LOGIN_ERROR = false
    
    loginOptions =
      popup     : true
      connection: provider
      error     : loginFailure
      success   : loginSuccess

    $authService.login(loginOptions)
    ###
    state = vm.retUrl
    unless state
      # TODO: home?
      state = $state.href 'home', {}, { absolute: true }
    callbackUrl = $state.href 'SOCIAL_CALLBACK', {retUrl : encodeURIComponent(state)}, { absolute: true }
    authUrl = AuthService.generateSSOUrl provider, callbackUrl
    $log.info 'redirecting to ' + authUrl
    $window.location.href = authUrl;
    ###

  vm.login = ->
    # loading
    vm.loading = true
    # clear error flags
    vm.loginErrors.USERNAME_NONEXISTANT = false
    vm.loginErrors.WRONG_PASSWORD = false
    vm.loginErrors.SOCIAL_LOGIN_ERROR = false

    validateUsername(vm.username)
      .then (result) ->
        if result
          vm.loginErrors.USERNAME_NONEXISTANT = true
        else
          login(vm.username, vm.currentPassword)
      .catch (err) ->
        vm.loginErrors.USERNAME_NONEXISTANT = false
        login(vm.username, vm.currentPassword)
  
  validateUsername = (username) ->
    validator = if Utils.isEmail(username) then UserService.validateEmail else UserService.validateHandle
    validator username
      .then (res) ->
        res?.valid
  
  login = (username, password) ->
    # Auth0 connection
    # handle: "LDAP", email: "TC-User-Database"
    conn = if Utils.isEmail(username) then 'TC-User-Database' else 'LDAP'

    loginOptions =
      username  : username
      password  : password
      connection: conn
      error     : loginFailure
      success   : loginSuccess

    AuthService.login loginOptions


  loginFailure = (res) ->
    $log.warn(res)
    vm.loading = false
    
    if res?.data?.result?.content?.toLowerCase() == 'account inactive'
      # redirect to the page to prompt activation 
      $log.info 'redirect to #{vm.confirmActivationUrl}'
      $window.location = vm.confirmActivationUrl
    else if res?.status == 401
      vm.loginErrors.SOCIAL_LOGIN_ERROR = true
    else
      vm.loginErrors.WRONG_PASSWORD = true
      vm.password = ''
    
  loginSuccess = ->
    vm.loading = false
    
    # setup login event for analytics tracking
    Utils.setupLoginEventMetrics(vm.username)
    
    jwt = TokenService.getAppirioJWT()
    if vm.retUrl
      redirectUrl = Utils.generateReturnUrl vm.retUrl
      $log.info 'redirect back to ' + redirectUrl
      $window.location = redirectUrl
    else
        $state.go 'home'

  init = ->
    jwt = TokenService.getAppirioJWT()
    if jwt && vm.retUrl
      redirectUrl = Utils.generateReturnUrl vm.retUrl
      $log.info 'redirect back to ' + redirectUrl
      $window.location = redirectUrl
    else if ($stateParams.handle || $stateParams.email) && $stateParams.password
      id = $stateParams.handle || $stateParams.email
      pass = $stateParams.password
      loginOptions =
        username: id
        password: pass
        error   : loginFailure
        success : loginSuccess
      AuthService.login loginOptions
    else
      vm.init = true
    vm
  
  init()


TCLoginController.$inject = [
  '$log'
  '$scope'
  '$rootScope'
  '$location'
  '$window'
  '$state'
  '$stateParams'
  '$timeout'
  '$authService'
  'AuthService'
  'TokenService'
  'UserService'
  'Utils'
  'Constants'
]

angular.module('accounts').controller 'TCLoginController', TCLoginController
