'use strict'

{ sendResetEmail } = require '../../../core/auth.js'

ForgotPasswordController = ($scope) ->
  vm          = this
  vm.email    = ''
  vm.error    = ''
  vm.success  = false

  vm.submit = ->
    vm.error   = false
    email      = encodeURIComponent vm.email

    sendResetEmail(email).then(success, failure)

  success = ->
    $scope.$apply ->
      vm.success = true

  failure = (error) ->
    $scope.$apply ->
      vm.error = error.message

  vm

ForgotPasswordController.$inject = [
  '$scope'
]

angular.module('accounts').controller 'ConnectForgotPasswordController', ForgotPasswordController


