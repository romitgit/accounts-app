
`import Auth0 from "auth0-js";`

'use strict'

config = (
  $locationProvider
  $stateProvider
  authProvider
  AUTH0_DOMAIN
  AUTH0_CLIENT_ID
  ) ->
  
  states = {}

  $locationProvider.html5Mode true

  # customer routes
  
  states['home'] =
    url         : '/'
    title       : 'Home'
    controller  : 'HomeController as vm'
    template    : require('./views/home')()
  
  states['login'] =
    url: '/login?retUrl&handle&password'
    title: 'Login'
    controller  : 'LoginController as vm'
    template: require('./views/login')()
    public: true

  states['logout'] =
    url: '/logout'
    title: 'Logout'
    controller  : 'LogoutController as vm'
    template: require('./views/logout')()
    public: true

  states['MEMBER_LOGIN'] =
    url: '/tc?retUrl&handle&password'
    controller  : 'TCLoginController as vm'
    template: require('./views/tc/login')()
    public: true
    
  states['SOCIAL_CALLBACK'] =
    url: '/social-callback?retUrl&userJWTToken&tcjwt&tcsso&status&message'
    template   : require('./views/tc/social-callback')()
    controller : 'SSOCallbackController as vm'
    public: true

  states['CONNECT_LOGIN'] =
    url: '/connect?retUrl&handle&password'
    controller  : 'LoginController as vm'
    template: require('./views/connect/login')()
    public: true

  states['SSO_LOGIN'] =
    url: '/sso-login/:org?retUrl'
    template   : require('./views/connect/sso-login')()
    controller : 'SSOLoginController as vm'
    public: true

  states['SSO_CALLBACK'] =
    url: '/sso-callback?retUrl&userJWTToken&tcjwt&tcsso&status&message'
    template   : require('./views/connect/sso-callback')()
    controller : 'SSOCallbackController as vm'
    public: true
  
  # This must be the last one in the list
  states['otherwise'] =
    url: '*path',
    template   : require('./views/404')()
    public: true

  for key, state of states
    $stateProvider.state key, state
  
  # Setup Auth0
  authProvider.init({
    domain: AUTH0_DOMAIN
    clientID: AUTH0_CLIENT_ID
    sso: false
  }, Auth0)


config.$inject = [
  '$locationProvider'
  '$stateProvider'
  'authProvider'
  'AUTH0_DOMAIN'
  'AUTH0_CLIENT_ID'
]

angular.module('accounts').config config

