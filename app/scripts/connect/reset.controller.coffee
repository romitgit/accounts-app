'use strict'

{ resetPassword } = require '../../../core/auth.js'

ResetPasswordController = ($stateParams, $state, $scope) ->
  vm          = this
  vm.password = ''
  vm.success  = false
  vm.error    = ''
  token       = $stateParams.token
  handle      = $stateParams.handle

  vm.submit = ->
    vm.error = false

    resetPassword(handle, token, vm.password).then(success, failure)

  success = ->
    $state.go 'CONNECT_LOGIN', { passwordReset: true }

  failure = (error) ->
    $scope.$apply ->
      vm.error = error.message

  vm

ResetPasswordController.$inject = [
  '$stateParams'
  '$state'
  '$scope'
]

angular.module('accounts').controller 'ConnectResetPasswordController', ResetPasswordController


