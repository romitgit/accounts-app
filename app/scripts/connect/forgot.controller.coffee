'use strict'

{ sendResetEmail } = require '../../../core/auth.js'

ForgotPasswordController = ($scope, $state) ->
  vm          = this
  vm.email    = ''
  vm.error    = ''
  vm.success  = false

  vm.submit = ->
    vm.error   = false
    email      = vm.email
    resetPasswordUrlPrefix = $state.href('CONNECT_RESET_PASSWORD', {}, { absolute: true })

    sendResetEmail(email, resetPasswordUrlPrefix).then(success, failure)

  success = ->
    $scope.$apply ->
      vm.success = true

  failure = (error) ->
    $scope.$apply ->
      vm.error = error.message

  vm

ForgotPasswordController.$inject = [
  '$scope'
  '$state'
]

angular.module('accounts').controller 'ConnectForgotPasswordController', ForgotPasswordController


