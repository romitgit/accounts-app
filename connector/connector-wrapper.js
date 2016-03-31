import { GET_TOKEN_REQUEST, GET_TOKEN_SUCCESS, GET_TOKEN_FAILURE, REFRESH_TOKEN_REQUEST, REFRESH_TOKEN_SUCCESS, REFRESH_TOKEN_FAILURE } from '../core/constants.js'
import iframe from './iframe.js'

let loading = new Promise(function(resolve, reject) {
  iframe.onload = function() {
    loading = false
    resolve()
  }
})

const proxyCall = function(REQUEST, SUCCESS, FAILURE, params = {}) {
  function request() {
    return new Promise( function(resolve, reject) {
      function receiveMessage(e) {
        console.log('host event', e.data)
        window.removeEventListener('message', receiveMessage)

        if (e.data.type === SUCCESS) resolve(e.data)
        if (e.data.type === FAILURE) reject(e.error)
      }

      window.addEventListener('message', receiveMessage)

      const payload = Object.assign({}, { type: REQUEST }, params)

      iframe.contentWindow.postMessage(payload, 'http://localhost:8000')
    })
  }

  if (loading) {
    return loading = loading.then(request)
  } else {
    return request()
  }
}

export const getToken = function () {
  return proxyCall(GET_TOKEN_REQUEST, GET_TOKEN_SUCCESS, GET_TOKEN_FAILURE)
    .then( data => data.token )
}

export const refreshToken = function () {
  return proxyCall(REFRESH_TOKEN_REQUEST, REFRESH_TOKEN_SUCCESS, REFRESH_TOKEN_FAILURE)
    .then( data => data.token )
}
