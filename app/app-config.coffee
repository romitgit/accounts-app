
`import Auth0 from "auth0-js";`
`import { AUTH0_DOMAIN, AUTH0_CLIENT_ID } from "../core/constants.js"`

'use strict'

config = (
  $locationProvider
  $stateProvider
  authProvider
) ->
  
  states = {}

  $locationProvider.html5Mode true

  # customer routes
  
  states['home'] =
    url         : '/'
    title       : 'Home'
    controller  : 'HomeController as vm'
    template    : require('./views/home')()

  # State parameters
  # app      : tc|connect|etc..
  # retUrl   : URL to redirect after authentication
  # handle   : direct login with handle/password
  # password : direct login with handle/password
  # return_to: URL of Zendesk to redirect after authentication. This is handed by Zendesk.
  # 
  # Connect example:
  # /login?app=connect&retUrl=https%3A%2F%2Fconnect.topcoder.com
  # Direct login example:
  # /login?app=connect&handle=jdoe&password=xxxxxx&retUrl=https%3A%2F%2Fconnect.topcoder.com
  # Zendesk example:
  # /login?app=zendesk&return_to=https%3A%2F%2Ftopcoder.zendesk.com
  states['login'] =
    url: '/login?app&retUrl&handle&password&return_to'
    title: 'Login'
    controller  : 'LoginController as vm'
    template: require('./views/login')()
    public: true

  # State parameters
  # retUrl  : URL to redirect after logging out
  # message : A message handed by Zendesk when some error occurs
  # 
  # Example:
  # /logout?retUrl=https%3A%2F%2Fconnect.topcoder.com
  # Zendesk example:
  # /logout?retUrl=https%3A%2F%2Ftopcoder.zendesk.com%2F
  # Zendesk Error example:
  # /logout?kind=error&message=User%20is%20invalid:%20External%20has%20already%20been%20taken&retUrl=https:%2F%2Fkohata.zendesk.com%2F
  states['logout'] =
    url: '/logout?retUrl&message'
    title: 'Logout'
    controller  : 'LogoutController as vm'
    template: require('./views/logout')()
    public: true
    
  # State parameters
  # client_id    : (required) ID for a client which is registered in the client database.
  # response_type: (required) Only "token" is supported.
  # redirect_uri : (required) Encoded URL to redirect after authentication. This should be registered in the client database.
  # state        : (optional)
  # scope        : (optional) Currently not used in anywhere.
  states['OAUTH'] =
    url: '/oauth?client_id&response_type&state&redirect_uri&scope'
    controller  : 'OAuthController as vm'
    public: true
  
  states['MEMBER_LOGIN'] =
    url: '/member?retUrl&handle&password&return_to&client_id&response_type&state&redirect_uri&scope'
    controller  : 'TCLoginController as vm'
    template: require('./views/tc/login')()
    public: true

  states['MEMBER_REGISTRATION'] =
    url: '/member/registration?retUrl'
    controller  : 'TCRegistrationController as vm'
    template: require('./views/tc/register.jade')()
    public: true

  states['MEMBER_REGISTRATION_SUCCESS'] =
    url: '/member/registration-success'
    template: require('./views/tc/registered-successfully.jade')()
    public: true

  states['MEMBER_FORGOT_PASSWORD'] =
    url: '/member/forgot-password'
    controller  : 'TCResetPasswordController as vm'
    template   : require('./views/tc/reset-password.jade')()
    public: true

  states['MEMBER_RESET_PASSWORD'] =
    url: '/member/reset-password?token&handle'
    controller  : 'TCResetPasswordController as vm'
    template   : require('./views/tc/reset-password.jade')()
    public: true
    
  states['SOCIAL_CALLBACK'] =
    url: '/social-callback?retUrl&userJWTToken&status&message'
    template   : require('./views/tc/social-callback')()
    controller : 'SSOCallbackController as vm'
    public: true

  states['CONNECT_LOGIN'] =
    url: '/connect?retUrl&handle&password'
    controller  : 'ConnectLoginController as vm'
    template: require('./views/connect/login')()
    public: true

  states['CONNECT_REGISTRATION'] =
    url: '/connect/registration?retUrl'
    controller  : 'ConnectRegistrationController as vm'
    template: require('./views/connect/registration.jade')()
    public: true

  states['CONNECT_REGISTRATION_SUCCESS'] =
    url: '/connect/registration-success'
    template: require('./views/connect/registration-success.jade')()
    public: true

  states['CONNECT_FORGOT_PASSWORD'] =
    url: '/connect/forgot-password'
    controller  : 'ConnectForgotPasswordController as vm'
    template   : require('./views/connect/forgot-password.jade')()
    public: true

  states['CONNECT_RESET_PASSWORD'] =
    url: '/connect/reset-password?token&handle'
    controller  : 'ConnectResetPasswordController as vm'
    template   : require('./views/connect/reset-password.jade')()
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

  states['UNAUTHORIZED'] =
    url: '/401',
    template   : require('./views/401')()
    public: true
  
  # This must be the last one in the list
  states['otherwise'] =
    url: '*path',
    template   : require('./views/404')()
    public: true

  for key, state of states
    $stateProvider.state key, state
  
  # Setup Auth0 (for Social Login)
  authProvider.init({
    domain: AUTH0_DOMAIN
    clientID: AUTH0_CLIENT_ID
    sso: false
  }, Auth0)


config.$inject = [
  '$locationProvider'
  '$stateProvider'
  'authProvider'
]

angular.module('accounts').config config

