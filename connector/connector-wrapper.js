import { GET_FRESH_TOKEN_REQUEST, GET_FRESH_TOKEN_SUCCESS, GET_FRESH_TOKEN_FAILURE, LOGOUT_REQUEST, LOGOUT_SUCCESS, LOGOUT_FAILURE, DOMAIN } from '../core/constants.js'
import createFrame from './iframe.js'

let iframe = null
let loading = null
let url = ''
let mock = false
let token = ''

export function configureConnector({connectorUrl, frameId, mockMode, mockToken}) {
  if (mockMode) {
    mock = true
    token = mockToken
  } else if (iframe) {
    console.warn('tc-accounts connector can only be configured once, this request has been ignored.')
  } else {
    iframe = createFrame(frameId, connectorUrl)
    url = connectorUrl 
    
    loading = new Promise( (resolve) => {
      iframe.onload = function() {
        loading = null
        resolve()
      }
    })
  }
}

const proxyCall = function(REQUEST, SUCCESS, FAILURE, params = {}) {
  if (mock) {
    throw new Error('connector is running in mock mode. This method (proxyCall) should not be invoked.')
  }

  if (!iframe) {
    throw new Error('connector has not yet been configured.')
  }

  function request() {
    return new Promise( (resolve, reject) => {
      function receiveMessage(e) {
        // ignore anything that is not our message
        // check origin and more strict message format
        var origin = e.origin || e.originalEvent.origin;
        const safeOrigin = origin && origin.endsWith(DOMAIN)
        const safeFormat = e.data.type === SUCCESS || e.data.type === FAILURE
        if (safeOrigin && safeFormat) {
          window.removeEventListener('message', receiveMessage)

          if (e.data.type === SUCCESS) resolve(e.data)
          if (e.data.type === FAILURE) reject(e.error)
        }
      }

      window.addEventListener('message', receiveMessage)

      const payload = Object.assign({}, { type: REQUEST }, params)

      iframe.contentWindow.postMessage(payload, url)
    })
  }

  if (loading) {
    return loading = loading.then(request)
  } else {
    return request()
  }
}

export function getFreshToken() {
  if (mock) {
    if (token) {
      return Promise.resolve(token)
    } else {
      return Promise.reject('connector is running in mock mode, but no token has been specified.')
    }
  }

  return proxyCall(GET_FRESH_TOKEN_REQUEST, GET_FRESH_TOKEN_SUCCESS, GET_FRESH_TOKEN_FAILURE)
    .then( data => data.token )
}

export function logout() {
  return proxyCall(LOGOUT_REQUEST, LOGOUT_SUCCESS, LOGOUT_FAILURE)
}
