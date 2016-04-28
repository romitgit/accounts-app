import 'babel-polyfill'

import { GET_FRESH_TOKEN_REQUEST, GET_FRESH_TOKEN_SUCCESS, GET_FRESH_TOKEN_FAILURE, LOGOUT_REQUEST, LOGOUT_SUCCESS, LOGOUT_FAILURE } from '../core/constants.js'
import { getToken, getFreshToken, refreshToken, logout } from '../core/auth.js'

function bindHandler(REQUEST, SUCCESS, FAILURE, action) {
  window.addEventListener('message', function(e) {
    function success(data) {
      const response = Object.assign({
        type: SUCCESS
      }, data)

      console.log('Connector iframe: sending response', response)

      e.source.postMessage(response, e.origin)
    }

    function failure(data) {
      if (data instanceof Error) {
        data = { error: data.message }
      }

      const response = Object.assign({
        type: FAILURE
      }, data)

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