'use strict'

FooterController = (
  $log,
  $sce
) ->
  
  vm = this
  vm.currentYear = new Date().getFullYear()
  
  init = ->
    vm.copyrightNotice = '&copy; ' + vm.currentYear + ' Topcoder. All Rights Reserved'
    vm.copyrightNotice = $sce.trustAsHtml vm.copyrightNotice
    vm
  
  init()
  

FooterController.$inject = [
  '$log',
  '$sce'
]

angular.module('accounts').controller 'FooterController', FooterController
