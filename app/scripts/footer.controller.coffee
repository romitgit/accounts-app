'use strict'

FooterController = (
  $log
) ->
  
  vm = this
  vm.currentYear = new Date().getFullYear()
  
  init = ->
    vm
  
  init()
  

FooterController.$inject = [
  '$log'
]

angular.module('accounts').controller 'FooterController', FooterController
