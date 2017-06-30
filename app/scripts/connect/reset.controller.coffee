'use strict'

{ resetPassword } = require '../../../core/auth.js'

ResetPasswordController = ($stateParams, $state, $scope) ->
  vm          = this
  vm.password = ''
  vm.success  = false
  vm.error    = ''
  vm.loading  = false
  token       = $stateParams.token
  handle      = $stateParams.handle
  vm.loginUrl    = $state.href('CONNECT_LOGIN', {}, { absolute: true })

  vm.submit = ->
    vm.error = false
    vm.loading  = true

    resetPassword(handle, token, vm.password).then(success, failure)

  success = ->
    $scope.$apply ->
      vm.loading  = false
      vm.success  = true
    # $state.go 'CONNECT_LOGIN', { passwordReset: true }

  failure = (error) ->
    $scope.$apply ->
      vm.error    = error.message
      vm.loading  = false

  vm

ResetPasswordController.$inject = [
  '$stateParams'
  '$state'
  '$scope'
]

angular.module('accounts').controller 'ConnectResetPasswordController', ResetPasswordController


