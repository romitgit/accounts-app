angular = require('angular');

# Module
dependencies = [
  'ui.router'
  'appirio-tech-ng-auth'
]

angular.module 'accounts', dependencies


# Constants
# see webpack.config.js
constants =
  ENV : process.env.ENV
  DOMAIN : process.env.DOMAIN
  APP_LOGOUT_URL : process.env.APP_LOGOUT_URL

angular.module('accounts').constant 'Constants', constants