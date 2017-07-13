import angular from 'angular'
import _ from 'lodash'
import { BUSY_PROGRESS_MESSAGE, DOMAIN, V3_JWT } from '../../../core/constants.js'
import { registerUser, socialRegistration } from '../../../core/auth.js'
import { npad } from '../../../core/utils.js'
import { getToken, decodeToken } from '../../../core/token.js'

(function() {
  'use strict'

  const SKILL_PICKER_URL = 'https://www.' + DOMAIN + '/skill-picker'

  angular.module('accounts').controller('TCRegistrationController', TCRegistrationController)

  TCRegistrationController.$inject = ['$log', '$scope', '$state', '$stateParams', 'UserService', 'ISO3166']

  function TCRegistrationController($log, $scope, $state, $stateParams, UserService, ISO3166) {
    var vm = this
    vm.registering = false
    vm.isSSORegistration = false
    vm.ssoUser = null
    // prepares utm params, if available
    var utm = {
      source : $stateParams && $stateParams.utm_source ? $stateParams.utm_source : '',
      medium : $stateParams && $stateParams.utm_medium ? $stateParams.utm_medium : '',
      campaign : $stateParams && $stateParams.utm_campaign ? $stateParams.utm_campaign : ''
    }

    // Set default for toggle password directive
    vm.defaultPlaceholder = 'Create Password'
    vm.busyMessage = BUSY_PROGRESS_MESSAGE
    vm.retUrl = $stateParams && $stateParams.retUrl ? $stateParams.retUrl : null
    vm.countries = ISO3166.getAllCountryObjects()

    vm.$stateParams = $stateParams

    vm.updateCountry = function (angucompleteCountryObj) {
      var countryCode = _.get(angucompleteCountryObj, 'originalObject.code', undefined)

      var isValidCountry = _.isUndefined(countryCode) ? false : true
      vm.registerForm.country.$setValidity('required', isValidCountry)
      vm.isValidCountry = isValidCountry
      if (isValidCountry) {
        vm.country = angucompleteCountryObj.originalObject
      }
    }

    vm.register = function() {
      vm.registering = true
      var userInfo = {
        handle: vm.username,
        firstName: vm.firstname,
        lastName: vm.lastname,
        email: vm.email,
        country: {
          code: npad(vm.country.code, 3),
          isoAlpha3Code: vm.country.alpha3,
          isoAlpha2Code: vm.country.alpha2
        },
        utmSource: utm.source,
        utmMedium: utm.medium,
        utmCampaign: utm.campaign
      }

      if (!vm.isSocialRegistration && !vm.ssoUser) {// if not social or sso registration
        userInfo.credential = { password: vm.password }
      } else if (vm.ssoUser) {//SSO user
        userInfo.active = true, // activate in registration
        userInfo.profile = {
          name: vm.ssoUser.name,
          email: vm.ssoUser.email,
          providerType: 'samlp',
          provider: vm.ssoUser.ssoProvider,
          userId: vm.ssoUser.ssoUserId
        }
      } else {
        userInfo.profile = {
          userId: vm.socialUserId,
          name: vm.firstname + ' ' + vm.lastname,
          email: vm.socialProfile.email,
          emailVerified: vm.socialProfile.email_verified,
          providerType: vm.socialProvider,
          context: {
            handle: vm.username,
            accessToken: vm.socialContext.accessToken,
            auth0UserId: vm.socialProfile.user_id
          }
        }
      }
      var redirectURL = vm.retUrl ? vm.retUrl : SKILL_PICKER_URL;
      var body = {
        param: userInfo,
        options: {
          afterActivationURL: redirectURL
        }
      }

      registerUser(body)
      .then(function(data) {
        vm.registering = false
        $log.debug('Registered successfully')

        // In the future, go to dashboard
        $state.go('MEMBER_REGISTRATION_SUCCESS', { ssoUser : true })
      })
      .catch(function(err) {
        vm.registering = false

        $log.error('Error in registering new user', err)
      })
    }

    vm.socialRegister = function(provider) {
      vm.errMsg = null
      socialRegistration(provider, null)
      .then(function(resp) {
        if (resp.status === 'SUCCESS') {
          var socialData = resp.data
          vm.socialUserId = socialData.socialUserId
          vm.username = socialData.username
          if (socialData.username) {
            vm.registerForm.username.$setDirty()
          }
          vm.firstname = socialData.firstname
          if (socialData.firstname) {
            vm.registerForm.firstname.$setDirty()
          }
          vm.lastname = socialData.lastname
          if (socialData.lastname) {
            vm.registerForm.lastname.$setDirty()
          }
          if (socialData.email) {
            vm.registerForm.email.$setDirty()
          }
          vm.email = socialData.email
          vm.socialProfile = socialData.socialProfile
          vm.socialProvider = socialData.socialProvider
          vm.socialContext= {'accessToken':  socialData.accessToken}
          vm.isSocialRegistration = true
        } else {
          vm.isSocialRegistration = false
        }
        $scope.$apply()
      })
      .catch(function(err) {
        switch (err.status) {
        case 'SOCIAL_PROFILE_ALREADY_EXISTS':
          vm.errMsg = 'An account with that profile already exists. Please login to access your account.'

          $log.error('Error registering user with social account', err)

          break

        default:
          vm.errMsg = 'Whoops! Something went wrong. Please try again later.'

          $log.error('Error registering user with social account', err)
        }
        vm.isSocialRegistration = false
        $scope.$apply()
      })
    }

    vm.ssoRegister = function() {
      vm.isSSORegistration = true
    }

    vm.ssoRegisterCancel = function() {
      vm.isSSORegistration = false
    }

    vm.onSSORegister = function(ssoUser) {
      vm.isSSORegistration = false
      vm.ssoUser = ssoUser
      
      if (ssoUser && ssoUser.firstName) {
        vm.firstname = ssoUser.firstName
        vm.registerForm.firstname.$setDirty()
      }
      if (ssoUser && ssoUser.lastName) {
        vm.lastname = ssoUser.lastName
        vm.registerForm.lastname.$setDirty()
      }
      if (ssoUser && ssoUser.email) {
        vm.email = ssoUser.email
        vm.registerForm.email.$setDirty()
      }
    }
  }
})()
