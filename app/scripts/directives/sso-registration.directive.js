import angular from 'angular'
import { ssoRegistration as registerWithSSO } from '../../../core/auth.js'
import { WIPRO_SSO_PROVIDER } from '../../../core/constants.js'

(function() {
  'use strict'

  angular.module('accounts.directives').directive('ssoRegistration', ssoRegistration)

  function ssoRegistration() {
    return {
      restrict: 'E',
      template: require('../../views/directives/sso-registration.directive')(),
      scope: {
        app: '=',
        onRegister: '&',
        onRegisterCancel: '&'
      },
      controllerAs: 'vm',
      controller: ['$scope', '$state', '$stateParams', '$log',
        function($scope, $state, $stateParams, $log) {

          var vm = this
          vm.loading       = false
          vm.error         = ''
          vm.emailOrHandle = ''
          vm.org           = $stateParams.org
          vm.app           = $stateParams.app

          activate()

          function activate() {
            if (vm.org) {
              go()
            }
          }

          vm.submit = function() {
            vm.org = WIPRO_SSO_PROVIDER
            go()
          }

          vm.showRegistrationPage = function() {
            $scope.onRegisterCancel()
          }

          function go() {
            vm.error = null
            vm.loading = true
            registerWithSSO(vm.org, null)
            .then(function(resp) {
              vm.loading = false
              if (resp.status === 'SUCCESS') {
                var socialData = resp.data
                vm.socialUserId = socialData.socialUserId
                $scope.onRegister({ssoUser : socialData})
              } else {
                vm.error = 'Whoops! Something went wrong. Please try again later.'
              }
              $scope.$apply()
            })
            .catch(function(err) {
              vm.loading = false
              vm.error = 'Whoops! Something went wrong. Please try again later.'
              $log.error('Error registering user with social account', err)
              $scope.$apply()
            })
          }
      }]
    }
  }
})()
