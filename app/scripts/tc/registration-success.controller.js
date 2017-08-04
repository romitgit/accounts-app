import angular from 'angular'

(function() {
  'use strict'


  angular.module('accounts').controller('TCRegistrationSuccessController', TCRegistrationSuccessController)

  TCRegistrationSuccessController.$inject = ['$log', '$stateParams']

  function TCRegistrationSuccessController($log, $stateParams) {
    var vm = this
    vm.ssoUser = $stateParams && $stateParams.ssoUser == true
    vm.retUrl  = $stateParams && $stateParams.retUrl
    $log.debug('Registration success, ssoUser = ' + vm.ssoUser)
    $log.debug('Registration success, retUrl = ' + vm.retUrl)
  }
})()
