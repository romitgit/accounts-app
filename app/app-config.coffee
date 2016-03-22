
config = ($locationProvider, $stateProvider) ->
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
    url: '/sso-callback'
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

config.$inject = ['$locationProvider', '$stateProvider']

angular.module('accounts').config config

