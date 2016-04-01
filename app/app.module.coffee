angular = require('angular');

# Module
dependencies = [
  'ui.router'
  'ngMessages'
  'auth0'
  'appirio-tech-ng-auth'
]

angular.module 'accounts', dependencies


# Constants
# see webpack.config.js
constants =
  ENV : process.env.ENV
  DOMAIN : process.env.DOMAIN

angular.module('accounts').constant 'Constants', constants