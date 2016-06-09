run = ($log, $rootScope, $state, $urlRouter) ->
  $log.debug('run')
  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    $rootScope.stateLoading = true
  $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
    $rootScope.stateLoading = false

run.$inject = ['$log', '$rootScope', '$state', '$urlRouter']

angular.module('accounts').run run