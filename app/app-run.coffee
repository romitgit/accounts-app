run = ($log, $rootScope, $state, $urlRouter) ->
    $log.debug('run')

run.$inject = ['$log', '$rootScope', '$state', '$urlRouter']

angular.module('accounts').run run