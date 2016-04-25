import { GET_FRESH_TOKEN_REQUEST, GET_FRESH_TOKEN_SUCCESS, GET_FRESH_TOKEN_FAILURE, LOGOUT_REQUEST, LOGOUT_SUCCESS, LOGOUT_FAILURE, CONNECTOR_URL } from '../core/constants.js'
import createFrame from './iframe.js'

let iframe = null
let loading = null

export function configureConnector({connectorUrl, frameId}) {
  if (iframe) {
    console.warn('tc-accounts connector can only be configured once, this request has been ignored')
  } else {
    iframe = createFrame(frameId, connectorUrl)
    
    loading = new Promise( (resolve) => {
      iframe.onload = function() {
        loading = null
        resolve()
      }
    })
  }
}

const proxyCall = function(REQUEST, SUCCESS, FAILURE, params = {}) {
  if (!iframe) {
    throw new Error('connector has not yet been configured')
  }

  function request() {
    return new Promise( (resolve, reject) => {
      function receiveMessage(e) {
        console.log('host event', e.data)
        window.removeEventListener('message', receiveMessage)

        if (e.data.type === SUCCESS) resolve(e.data)
        if (e.data.type === FAILURE) reject(e.error)
      }

      window.addEventListener('message', receiveMessage)

      const payload = Object.assign({}, { type: REQUEST }, params)

      iframe.contentWindow.postMessage(payload, CONNECTOR_URL)
    })
  }

  if (loading) {
    return loading = loading.then(request)
  } else {
    return request()
  }
}

export function getFreshToken() {
  return proxyCall(GET_FRESH_TOKEN_REQUEST, GET_FRESH_TOKEN_SUCCESS, GET_FRESH_TOKEN_FAILURE)
    .then( data => data.token )
}

export function logout() {
  return proxyCall(LOGOUT_REQUEST, LOGOUT_SUCCESS, LOGOUT_FAILURE)
}
