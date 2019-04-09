import 'babel-polyfill'

import { GET_FRESH_TOKEN_REQUEST, GET_FRESH_TOKEN_SUCCESS, GET_FRESH_TOKEN_FAILURE, LOGOUT_REQUEST, LOGOUT_SUCCESS, LOGOUT_FAILURE, ALLOWED_ORIGINS } from '../core/constants.js'
import { getFreshToken, logout } from '../core/auth.js'
import { extractNakedDomain } from '../core/utils'

function bindHandler(REQUEST, SUCCESS, FAILURE, action) {
  window.addEventListener('message', (e) => {

    var origin = e.origin || e.originalEvent.origin,
        validOrigin = false;
    
    ALLOWED_ORIGINS.forEach((allowedOrigin) => {
      if (!validOrigin) {
        if (extractNakedDomain(allowedOrigin) === extractNakedDomain(origin)) {
          validOrigin = true
        }
      }
    })

    if (!validOrigin) {
      console.error(origin, 'is not allowed');
      return;
    }

    function success(data) {
      const response = Object.assign({
        type: SUCCESS
      }, data)

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

      e.source.postMessage(response, e.origin)
    }

    if (e.data.type === REQUEST) {
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
