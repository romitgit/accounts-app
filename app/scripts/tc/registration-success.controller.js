import angular from 'angular'

(function() {
  'use strict'


  angular.module('accounts').controller('TCRegistrationSuccessController', TCRegistrationSuccessController)

  TCRegistrationSuccessController.$inject = ['$log' '$stateParams']

  function TCRegistrationSuccessController($log, $stateParams) {
    var vm = this
    vm.ssoUser = $stateParams && $stateParams.ssoUser == true
    $log.debug('Registration success, ssoUser = ' + vm.ssoUser)
  }
})()
