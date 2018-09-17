import angular from 'angular'
import {react2angular} from 'react2angular'
import {LoginScreen, Wizard} from 'appirio-tech-react-components'

angular
.module('accounts.react.login', [])
.component('loginScreen', react2angular(LoginScreen, ['vm']))

angular
.module('accounts.react.register', [])
.component('registerScreen', react2angular(Wizard, ['vm', 'type']))

angular
.module('accounts.react.pin', [])
.component('pinVerificationScreen', react2angular(Wizard, ['vm', 'type']))

angular
.module('accounts.react.welcome', [])
.component('welcomeScreen', react2angular(Wizard, ['vm', 'type']))

