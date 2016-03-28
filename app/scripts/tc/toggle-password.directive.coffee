'use strict'

directive = ->
  restrict : 'E'
  require  : '^form'
  link: (scope, element, attrs, formController) ->
    vm = scope.vm
    vm.currentPassword = ''
    scope.currentPasswordDefaultPlaceholder = attrs.placeholder || 'Password'
    scope.currentPasswordPlaceholder = scope.currentPasswordDefaultPlaceholder
    
    currentPasswordInput = element.children()[0]
    
    element.bind 'click', (event) ->
      currentPasswordInput?.focus()
    
    element.bind 'keyup', (event) ->
      if event.keyCode == 13
        currentPasswordInput?.blur()

    vm.onCPFocus = (event) ->
      scope.currentPasswordPlaceholder = ''
      element.addClass 'focus'
      dummy()
    
    vm.onCPBlur = (event) ->
      relatedTarget = angular.element event.relatedTarget
      element.removeClass 'focus'

      # If you are blurring from the password input and clicking the checkbox
      if relatedTarget.attr('type') == 'checkbox' && relatedTarget.attr('id') == 'currentPasswordCheckbox'
        scope.currentPasswordPlaceholder = ''
        currentPasswordInput.focus()
      else if vm.currentPassword == '' || vm.currentPassword == undefined
        scope.currentPasswordPlaceholder = scope.currentPasswordDefaultPlaceholder
        formController.currentPassword.$setPristine()
      dummy()

    vm.toggleTypeAttribute = ->
      $currentPasswordInput = angular.element(currentPasswordInput)
      if $currentPasswordInput.attr('type') == 'text'
        $currentPasswordInput.attr('type', 'password')
      else
        $currentPasswordInput.attr('type', 'text')
      dummy()

    # To avoid causing the security error
    # https://docs.angularjs.org/error/$parse/isecdom
    dummy = ->
      false

angular.module('accounts').directive 'togglePassword', directive
