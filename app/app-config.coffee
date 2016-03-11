
config = ($locationProvider, $stateProvider) ->
  states = {}

  $locationProvider.html5Mode true

  # customer routes
  
  states['home'] =
    url         : '/'
    title       : 'Home'
    controller  : 'HomeController as vm'
    template    : require('./views/home')()
  
  # general routes
  
  states['login'] =
    url: '/login'
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

  # This must be the last one in the list
  states['otherwise'] =
    url: '*path',
    template   : require('./views/404')()
    public: true

  for key, state of states
    $stateProvider.state key, state

config.$inject = ['$locationProvider', '$stateProvider']

angular.module('accounts').config config

