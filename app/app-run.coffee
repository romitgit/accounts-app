run = ($log, $rootScope, $state, $urlRouter) ->
  $log.debug('run')
  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    $rootScope.stateLoaded = false
  $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
    $rootScope.stateLoaded = true

run.$inject = ['$log', '$rootScope', '$state', '$urlRouter']

angular.module('accounts').run run