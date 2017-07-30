'use strict'

{ sendResetEmail } = require '../../../core/auth.js'

ForgotPasswordController = ($scope, $state) ->
  vm          = this
  vm.email    = ''
  vm.error    = ''
  vm.success  = false
  vm.loading  = false

  vm.submit = ->
    vm.loading = true
    vm.error   = false
    email      = vm.email
    if email == '' || email == undefined
      vm.error = 'Error email is required'
      vm.loading = false
    else
      resetPasswordUrlPrefix = $state.href('CONNECT_RESET_PASSWORD', {}, { absolute: true })

      sendResetEmail(email, resetPasswordUrlPrefix).then(success, failure)

  success = ->
    $scope.$apply ->
      vm.success = true
      vm.loading = false

  failure = (error) ->
    $scope.$apply ->
      vm.error = error.message
      vm.loading = false

  vm

ForgotPasswordController.$inject = [
  '$scope'
  '$state'
]

angular.module('accounts').controller 'ConnectForgotPasswordController', ForgotPasswordController


