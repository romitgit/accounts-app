import 'babel-polyfill'

import { GET_FRESH_TOKEN_REQUEST, GET_FRESH_TOKEN_SUCCESS, GET_FRESH_TOKEN_FAILURE, LOGOUT_REQUEST, LOGOUT_SUCCESS, LOGOUT_FAILURE, ALLOWED_ORIGINS } from '../core/constants.js'
import { getFreshToken, logout } from '../core/auth.js'

function bindHandler(REQUEST, SUCCESS, FAILURE, action) {
  window.addEventListener('message', (e) => {

    var origin = e.origin || e.originalEvent.origin;
    if (ALLOWED_ORIGINS.indexOf(origin) === -1) {
      console.error(origin, 'is not allowed');
      return;
    }

    function success(data) {
      const response = Object.assign({
        type: SUCCESS
      }, data)

      console.log('Connector iframe: sending response', response)

      var origin = e.origin || e.originalEvent.origin;
      e.source.postMessage(response, origin)
    }

    function failure(error) {
      if (error instanceof Error) {
        error = { error: error.message }
      }

      if (typeof error === 'string') {
        error = { error }
      }

      const response = Object.assign({
        type: FAILURE
      }, error)

      console.log('Connector iframe: sending response', response)

      e.source.postMessage(response, e.origin)
    }

    if (e.data.type === REQUEST) {
      console.log('Connector iframe: request received', e.data)
      action(success, failure)
    }
  })
}

bindHandler(GET_FRESH_TOKEN_REQUEST, GET_FRESH_TOKEN_SUCCESS, GET_FRESH_TOKEN_FAILURE, (sendSuccess, sendError) => {
  function success(token) {
    sendSuccess({ token })
  }

  getFreshToken().then(success, sendError)
})

bindHandler(LOGOUT_REQUEST, LOGOUT_SUCCESS, LOGOUT_FAILURE, (sendSuccess, sendError) => {
  function success(response ) {
    sendSuccess({ response  })
  }

  logout().then(success, sendError)
})