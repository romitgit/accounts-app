import { GET_TOKEN_REQUEST, GET_TOKEN_SUCCESS, GET_TOKEN_FAILURE, REFRESH_TOKEN_REQUEST, REFRESH_TOKEN_SUCCESS, REFRESH_TOKEN_FAILURE } from '../core/constants.js'
import { getToken, refreshToken } from '../core/auth.js'

window.addEventListener('message', function(e) {
  if (e.data.type === GET_TOKEN_REQUEST) {
    console.log('iframe event', e.data)
    const token = getToken()

    if (token) {
      e.source.postMessage({
        type: GET_TOKEN_SUCCESS,
        token
      }, e.origin)
    } else {
      e.source.postMessage({
        type: GET_TOKEN_FAILURE
      }, e.origin)
    }
  }
})

window.addEventListener('message', function(e) {
  function success(token) {
    e.source.postMessage({
      type: REFRESH_TOKEN_SUCCESS,
      token
    }, e.origin)
  }

  function failure(error) {
    e.source.postMessage({
      type: REFRESH_TOKEN_FAILURE
    }, e.origin)
  }

  if (e.data.type === REFRESH_TOKEN_REQUEST) {
    console.log('iframe event', e.data)
    refreshToken().then(success, failure)
  }
})