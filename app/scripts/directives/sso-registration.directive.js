import angular from 'angular'
import { ssoRegistration as registerWithSSO } from '../../../core/auth.js'
import { WIPRO_SSO_PROVIDER, TOPCODER_SSO_PROVIDER, APPIRIO_SSO_PROVIDER, SSO_PROVIDER_DOMAINS,
  SSO_PROVIDER_DOMAIN_WIPRO, SSO_PROVIDER_DOMAIN_APPIRIO, SSO_PROVIDER_DOMAIN_TOPCODER
} from '../../../core/constants.js'

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

          function identifySSOProvider(emailOrHandle) {
            var EMAIL_DOMAIN_REGEX = new RegExp('^[a-zA-Z0-9_.+-]+@(?:(?:[a-zA-Z0-9-]+\\.)?[a-zA-Z]+\\.)?(' + SSO_PROVIDER_DOMAINS + ')\\.[a-zA-Z]{2,15}$')
            var match = EMAIL_DOMAIN_REGEX.exec(emailOrHandle)
            var domain, provider = null
            if (match && match.length > 1) {
              domain = match[1]
            }
            // identify SSO provider by looking at domain of the email or handle
            // if handle does not follow email pattern, this won't work
            switch(domain) {
            case SSO_PROVIDER_DOMAIN_WIPRO:
              provider = WIPRO_SSO_PROVIDER
              break
            case SSO_PROVIDER_DOMAIN_APPIRIO:
              provider = APPIRIO_SSO_PROVIDER
              break
            case SSO_PROVIDER_DOMAIN_TOPCODER:
              provider = TOPCODER_SSO_PROVIDER
              break
            default:
              break
            }
            return provider
          }

          vm.submit = function() {
            // reset the org
            vm.org = identifySSOProvider(vm.emailOrHandle)

            if (vm.org) {
              go()
            } else {
              vm.error = 'Sorry!! Your SSO provider is not yet supported.'
            }
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
