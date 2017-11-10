{ SEGMENT_KEY }   = require '../core/constants.js'
{ isAuth0Hosted } = require '../core/auth.js'

run = ($log, $rootScope, $state, $urlRouter, $location) ->
  $log.debug('run')
  window.analytics.load(SEGMENT_KEY);
  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    $rootScope.stateLoaded = false
  $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
    $rootScope.stateLoaded = true
    
    # hide common footer and banner for connect pages to allow new styled footer for connect
    $rootScope.hideCommonFooter = toState.url && toState.url.indexOf('/connect') != -1
    path = $location.path()
    queryString = ''
    referrer = ''
    
    # In the hosted login page the complete querystring should not be included for security reasons.
    # TODO: Check what information should be sent to analytics (Cliend ID)
    if ((path.indexOf '?' != -1) and !isAuth0Hosted())
      queryString = path.substring(path.indexOf('?'), path.length)
    if (fromState.name)
      referrer = $location.protocol() + '://' + $location.host() + '/#' + fromState.url

    window.analytics.page
      path: path,
      referrer: referrer,
      search: queryString,
      url: $location.absUrl()

run.$inject = ['$log', '$rootScope', '$state', '$urlRouter', '$location']

angular.module('accounts').run run
